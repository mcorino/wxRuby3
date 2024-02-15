# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 rake install support
###

require 'optparse'
require_relative './lib/config'

module WXRuby3

  module Install

    class << self
      def prefix
        @prefix
      end
      def prefix=(v)
        @prefix = v.to_s
      end

      def wxwin_shlibs
        unless @wxwin_shlibs
          @wxwin_shlibs = Rake::FileList.new
          # include wxWidgets shared libraries we linked with
          WXRuby3.config.wx_libs.select { |s| s.start_with?('-L') }.each do |libdir|
            libdir = libdir[2..libdir.size]
            libdir = File.join(File.dirname(libdir), 'bin').gsub('\\', '/') if WXRuby3.config.windows?
            WXRuby3.config.wx_libs.select { |s| s.start_with?('-l') }.each do |lib|
              lib = lib[2..lib.size]
              if WXRuby3.config.windows?
                # match only wxWidgets libraries
                if (m = /\Awx_([a-z]+)(_[a-z]+)?-(.*)/.match(lib))
                  # translate lib name to shlib name
                  grp_id = m[1]
                  lib_id = m[2]
                  ver = m[3].sub('.', '')
                  # as of wxw 3.3 there seems to be an additional digit added to the version part of the dll name
                  # so add a wildcard ('*') in that spot to match older and newer versions
                  lib = "wx#{grp_id.sub(/u\Z/, '')}#{ver}*u#{lib_id}"
                  @wxwin_shlibs.include File.join(libdir, "#{lib}*.#{WXRuby3.config.dll_mask}")
                end
              else
                # match only wxWidgets libraries
                if /\Awx(_osx)?_([a-z\d]+)(_[a-z]+)?-(.*)/.match(lib)
                  @wxwin_shlibs.include File.join(libdir, "lib#{lib}*.#{WXRuby3.config.dll_mask}")
                end
              end
            end
          end
          @wxwin_shlibs = ::Set.new(@wxwin_shlibs.to_a)
        end
        @wxwin_shlibs
      end

      def install_wxwin_shlibs
        if WXRuby3.config.get_config('with-wxwin')
          $stdout.print "Installing wxRuby3 extensions..." if WXRuby3.config.run_silent?
          # prepare required wxWidgets shared libs
          wxwin_inshlibs = []
          WXRuby3::Install.wxwin_shlibs.each do |shlib|
            if File.symlink?(shlib)
              src_shlib = shlib
              src_shlib = File.join(File.dirname(shlib), File.basename(File.readlink(src_shlib))) while File.symlink?(src_shlib)
              FileUtils.ln_s(File.join('.', File.basename(src_shlib)), File.join('ext', File.basename(shlib)))
            else
              FileUtils.cp(shlib, inshlib = File.join('ext', File.basename(shlib)))
              unless WXRuby3.config.update_shlib_loadpaths(inshlib)
                # cleanup and exit
                FileUtils.rm_f(Dir["ext/*.#{WXRuby3.config.dll_mask}"])
                exit(1)
              end
              wxwin_inshlibs << File.expand_path(inshlib)
            end
          end
          # prepare wxRuby shared libs
          Dir["lib/*.#{WXRuby3.config.dll_mask}"].each do |shlib|
            unless WXRuby3.config.update_shlib_loadpaths(shlib) && WXRuby3.config.update_shlib_ruby_libpath(shlib)
              # cleanup and exit
              FileUtils.rm_f(Dir["ext/*.#{WXRuby3.config.dll_mask}"])
              exit(1)
            end
          end
          (wxwin_inshlibs + Dir["lib/*.#{WXRuby3.config.dll_mask}"]).each do |shlib|
            unless WXRuby3.config.update_shlib_wxwin_libpaths(shlib, WXRuby3::Install.wxwin_shlibs)
              # cleanup and exit
              FileUtils.rm_f(Dir["ext/*.#{WXRuby3.config.dll_mask}"])
              exit(1)
            end
          end
          $stdout.puts 'done!' if WXRuby3.config.run_silent?
        end
      end

      def remove_wxwin_shlibs
        if WXRuby3.config.get_config('with-wxwin')
          WXRuby3::Install.wxwin_shlibs.each { |shlib| FileUtils.rm_f(File.join('ext', File.basename(shlib))) }
        end
      end

    end

    def self.define(task, args)
      #_argv = Rake.application.cleanup_args(ARGV) rescue exit(1)
      OptionParser.new do |opts|
        opts.banner = <<~__USAGE
          Usage: rake [RAKE_OPTIONS] #{task.name}[TASK_OPTIONS] [NO_HARM=1]

          TASK_OPTIONS need to be specified as '<taskname>[<opt>,<opt>,...]' without whitespaces.
          In case whitespaces are needed enclose the entire string in "" like "<taskname>[<opt>,<opt>,...]".
          __USAGE

        opts.separator ""

        opts.on('--prefix=path',
                "path prefix of target environment (default #{Install.prefix ? "'#{Install.prefix}'" : 'unset'})") {|v| Install.prefix = File.expand_path(v) }

        opts.separator ""

        opts.on('--help', 'Show this help message') { puts opts; puts; exit }

        opts.separator ""

        opts.separator "\tAdding 'NO_HARM=1' will run the command without actually executing any\n\tactions but only printing what it would do."

      end.parse!(args.extras.dup)
    end

    def self.nowrite(v = nil)
      # need to do this because of Rake version differences
      rv = Rake.__send__ :nowrite
      Rake.__send__(:nowrite, v) if v
      if block_given?
        begin
          yield
        ensure
          Rake.__send__(:nowrite, rv)
        end
      end
      rv
    end

    def self.verbose
      Rake.__send__ :verbose
    end

    def self.specs
      specs = [
        [WXRuby3.config.get_cfg_string('siterubyver'), ['lib/wx.rb'], 0644],
        [File.join(WXRuby3.config.get_cfg_string('siterubyver'), 'wx'), ['lib/wx'], 0644],
      ]
      # add wxRuby shared libraries
      WXRuby3::Director.each_package { |pkg| specs << [WXRuby3.config.get_cfg_string('siterubyverarch'), [pkg.lib_target], 0555] }
      if WXRuby3.config.get_config('with-wxwin')
        specs << [WXRuby3.config.get_cfg_string('siterubyverarch'), Install.wxwin_shlibs, 0555]
      end
      specs
    end

    def self.install
      WXRuby3::Install.specs.each do |dest, srclist, mode, match|
        srclist.each do |src|
          if File.directory?(src)
            install_dir(src, dest, mode, match)
          else
            install_file(src, dest, mode, match)
          end
        end
      end
    end

    def self.uninstall
      WXRuby3::Install.specs.each do |dest, srclist, _mode, match|
        srclist.each do |src|
          if File.directory?(src)
            uninstall_dir(src, dest, match)
          else
            uninstall_file(src, dest, match)
          end
        end
      end
    end

  end

  module InstallMethods

    def install_file(src, dest, mode, match)
      return unless match.nil? || match.call(src)
      dest = File.join(Install.prefix, dest) if Install.prefix
      FileUtils.mkdir_p(dest, :noop => nowrite, :verbose => verbose) unless File.directory?(dest)
      FileUtils.install(src, dest, :mode => mode, :noop => nowrite, :verbose => verbose)
    end
    def install_dir(dir, dest, mode, match)
      return unless match.nil? || match.call(dir)
      FileUtils.chdir(dir, :verbose => verbose) do
        Dir['*'].each do |entry|
          if File.directory?(entry)
            install_dir(entry, File.join(dest, entry), mode, match)
          else
            install_file(entry, dest, mode, match)
          end
        end
      end
    end
    def uninstall_file(src, dest, match)
      return unless match.nil? || match.call(src)
      dest = File.join(Install.prefix, dest) if Install.prefix
      dst_file = File.join(dest, File.basename(src))
      if nowrite || File.file?(dst_file)
        if nowrite || FileUtils.compare_file(src, dst_file)
          FileUtils.rm_f(dst_file, :noop => nowrite, :verbose => verbose)
        else
          STDERR.puts "ALERT: source (#{src}) differs from installed file (#{dst_file})"
        end
      end
    end
    def uninstall_dir(dir, dest, match)
      return unless match.nil? || match.call(dir)
      FileUtils.chdir(dir, :verbose => verbose) do
        Dir['*'].each do |entry|
          if File.directory?(entry)
            uninstall_dir(entry, File.join(dest, entry), match)
          else
            uninstall_file(entry, dest, match)
          end
        end
      end
      FileUtils.rmdir(dest, :noop => nowrite, :verbose => verbose)
    end

  end

  Install.singleton_class.include WXRuby3::InstallMethods

end
