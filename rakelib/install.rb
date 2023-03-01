###
# wxRuby3 rake install support
# Copyright (c) M.J.N. Corino, The Netherlands
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
        #[RbConfig::CONFIG['bindir'], ['bin'], 0755],
        [RbConfig::CONFIG['sitelibdir'], ['lib/wx.rb'], 0644],
        [RbConfig::CONFIG['sitelibdir'], ['lib/wx'], 0644],
      ]
      # add wxRuby shared libraries
      WXRuby3::Director.each_package { |pkg| specs << [RbConfig::CONFIG['sitearchdir'], [pkg.lib_target], 0555] }
      # unless get_config('without-tao')
      #   dll_ext = if R2CORBA::Config.is_win32
      #               '.dll'
      #             elsif R2CORBA::Config.is_osx
      #               '.dylib'
      #             else
      #               '.so.*'
      #             end
      #   dll_files = R2CORBA::Ext::ace_shlibs(dll_ext)
      #   dll_files = dll_files.collect {|p| Dir.glob(p).first } unless R2CORBA::Config.is_win32 || R2CORBA::Config.is_osx
      #   dll_files.concat(R2CORBA::Ext.sys_dlls) if R2CORBA::Config.is_win32
      #   specs << [get_config('aceinstdir'), dll_files, 0555]
      # end
      specs
    end

    def self.install
      WXRuby3::Install.specs.each do |dest, srclist, mode, match|
        srclist.each do |src|
          if File.directory?(src)
            install_dir(src, dest, mode, match)
          else
            install_file(src, dest, mode) if match.nil? || match =~ src
          end
        end
      end
      # R2CORBA::Ext::ace_shlibs('.so', get_config('aceinstdir')).each do |acelib|
      #   acelib = File.join(get_config(:prefix), acelib) if get_config(:prefix)
      #   libver = File.expand_path(Dir.glob(acelib+'.*').first || (nowrite ? acelib+'.x.x.x' : nil))
      #   FileUtils.ln_s(libver, acelib, :force => true, :noop => nowrite, :verbose => verbose)
      # end
    end

    def self.uninstall
      # R2CORBA::Ext::ace_shlibs('.so', get_config('aceinstdir')).each do |acelib|
      #   acelib = File.join(get_config(:prefix), acelib) if get_config(:prefix)
      #   FileUtils.rm_f(acelib, :noop => nowrite, :verbose => verbose) if nowrite || File.exist?(acelib)
      # end
      WXRuby3::Install.specs.each do |dest, srclist, mode, match|
        srclist.each do |src|
          if File.directory?(src)
            uninstall_dir(src, dest, match)
          else
            uninstall_file(src, dest) if match.nil? || match =~ src
          end
        end
      end
    end

  end

  module InstallMethods

    def install_file(src, dest, mode)
      dest = File.join(Install.prefix, dest) if Install.prefix
      FileUtils.mkdir_p(dest, :noop => nowrite, :verbose => verbose) unless File.directory?(dest)
      FileUtils.install(src, dest, :mode => mode, :noop => nowrite, :verbose => verbose)
    end
    def install_dir(dir, dest, mode, match)
      curdir = Dir.getwd
      begin
        FileUtils.cd(dir, :verbose => verbose)
        Dir.glob('*') do |entry|
          if File.directory?(entry)
            install_dir(entry, File.join(dest, entry), mode, match)
          else
            install_file(entry, dest, mode) if match.nil? || match =~ entry
          end
        end
      ensure
        FileUtils.cd(curdir, :verbose => verbose)
      end
    end
    def uninstall_file(src, dest)
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
      curdir = Dir.getwd
      begin
        FileUtils.cd(dir, :verbose => verbose)
        Dir.glob('*') do |entry|
          if File.directory?(entry)
            uninstall_dir(entry, File.join(dest, entry), match)
          else
            uninstall_file(entry, dest) if match.nil? || match =~ entry
          end
        end
      ensure
        FileUtils.cd(curdir, :verbose => verbose)
      end
    end

  end

end

include WXRuby3::InstallMethods
