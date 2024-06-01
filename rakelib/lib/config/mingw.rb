# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 buildtools configuration
###

require_relative './unixish'
require_relative 'pkgman/mingw'

require 'uri'


if ENV['RI_DEVKIT'].nil?
  begin
    require 'devkit'
  rescue LoadError
    STDERR.puts "Missing a fully installed & configured Ruby devkit. Make sure to install the Ruby devkit with MSYS2 and MINGW toolchains."
    exit(1)
  end
end

module WXRuby3

  module Config

    module Platform

      def self.included(base)
        base.class_eval do
          include Config::UnixLike

          attr_reader :rescomp

          alias :base_ldflags :ldflags
          def ldflags(target)
            "-Wl,-soname,#{File.basename(target)} #{base_ldflags(target)}"
          end

          def debug_command(*args)
            args.unshift(nix_path(FileUtils::RUBY))
            args.unshift('--args')
            args.unshift('gdb')
            args.join(' ')
          end

          # override accessor to guarantee win path
          def wx_setup_h
            if @wx_setup_h.index('/')
              @wx_setup_h = win_path(@wx_setup_h)
            end
            @wx_setup_h
          end

          def dll_mask
            "{#{dll_ext},dll}"
          end

          def do_link(pkg)
            # have to use option file for objects to link on windows because command line gets too long
            ftmp = Tempfile.new('object')
            ftmp.puts pkg.all_obj_files.collect { |o| File.join('..', o) }.join(' ')
            ftmp.close # close but do not unlink
            objs = "@#{ftmp.path}"
            depsh = pkg.dep_libnames.collect { |dl| "#{dl}.#{dll_ext}" }.join(' ')
            sh "cd lib && #{WXRuby3.config.ld} #{WXRuby3.config.ldflags(pkg.lib_target)} #{objs} #{depsh} " +
                 "#{WXRuby3.config.libs} #{WXRuby3.config.link_output_flag}#{pkg.lib_target}"
            ftmp.unlink # cleanup
          end

          def check_tool_pkgs
            pkg_deps = []
            pkg_deps << 'doxygen' if expand("which #{get_cfg_string('doxygen')} 2>/dev/null").strip.empty?
            pkg_deps << 'swig' if expand("which #{get_cfg_string('swig')} 2>/dev/null").strip.empty?
            pkg_deps << 'git' if expand("which #{get_cfg_string('git')} 2>/dev/null").strip.empty?
            pkg_deps
          end

          def install_prerequisites
            pkg_deps = super
            PkgManager.install(pkg_deps)
            []
          end

          def expand(cmd)
            super("bash -c \"#{cmd}\"")
          end

          def bash(*cmd, **kwargs)
            env = ::Hash === cmd.first ? cmd.shift : nil
            opts = ::Hash === cmd.last ? cmd.pop : nil
            cmd = ['bash', '-c', cmd.join(' ')]
            cmd.unshift(env) if env
            super(*cmd, **kwargs)
          end

          private

          def wx_configure
            bash('./configure --prefix=`pwd`/install --disable-tests --without-subdirs --without-regex --with-expat=builtin --with-zlib=builtin --disable-debug_info')
          end

          def wx_make
            bash('make && make install')
          end

          def wx_generate_xml
            doxygen = get_cfg_string("doxygen")
            doxygen = nix_path(doxygen) unless doxygen == 'doxygen'
            chdir(File.join(ext_path, 'wxWidgets', 'docs', 'doxygen')) do
              unless bash({ 'DOXYGEN' => doxygen,  'WX_SKIP_DOXYGEN_VERSION_CHECK' => '1' }, './regen.sh', 'xml')
                $stderr.puts 'ERROR: Failed to generate wxWidgets XML API specifications for parsing by wxRuby3.'
                exit(1)
              end
            end
          end

          def respawn_rake(argv = ARGV)
            Kernel.exec('rake', *argv)
          end

          def nix_path(winpath)
            (winpath.nil? || winpath.empty?) ? '' : `cygpath -a -u #{winpath}`.strip
          end

          # Allow specification of custom wxWidgets build (mostly useful for
          # static wxRuby3 builds)
          def win_path(nixpath)
            (nixpath.nil? || nixpath.empty?) ? '' : `cygpath -a -w #{nixpath}`.strip
          end

          def get_wx_path
            nix_path(super)
          end

        end
      end

      def init_platform
        init_unix_platform

        if @wx_version
          # need to convert these to windows paths
          @wx_cppflags.each { |flags| flags.gsub!(/-I(\S+)/) { |s| "-I#{win_path($1)}" } }
          @wx_libs.each { |libflag| libflag.gsub!(/-L(\S+)/) { |s| "-L#{win_path($1)}" } }

          @extra_cflags.concat %w[-Wno-unused-function -Wno-conversion-null -Wno-maybe-uninitialized -Wno-deprecated-copy]
          @extra_cflags << ' -Wno-deprecated-declarations' unless @no_deprecated

          # create a .dll binary
          @extra_ldflags << '-shared'

          @ruby_ldflags.each { |flags| flags.sub!(' $(DEFFILE)', '') } # cleanup for older RubyInstaller versions
          @ruby_ldflags.each { |flags| flags.gsub!(/-s(\s|\Z)/, '') } if @debug_build # do not strip debug symbols for debug build
          @ruby_ldflags << '-s' if @release_build  # strip debug symbols for release build
          @ruby_cppflags << RB_CONFIG['debugflags'] if @debug_build
          @ruby_cppflags.each { |flags| flags.gsub!(/-O\d/, '-O0') } if @debug_build # disable optimizations for debug build

          unless @wx_path.empty?
            exec_pfx = win_path(wx_config("--exec-prefix"))
            libdirs = [File.join(exec_pfx, 'bin')]
            libdirs << win_path(File.join(ENV['MSYSTEM_PREFIX'], 'bin'))
            @exec_env['RUBY_DLL_PATH'] = "#{ENV['RUBY_DLL_PATH']};#{dest_dir};#{libdirs.join(';')}"
          end

          @rescomp = wx_config('--rescomp').gsub(/--include-dir\s+(\S+)/) { |s| "--include-dir #{win_path($1)}" }
          @rescomp << " --include-dir #{@ext_path}"
          @rescomp << ' --define __WXMSW__ --define wxUSE_DPI_AWARE_MANIFEST=2 --define wxUSE_RC_MANIFEST=1 --define ISOLATION_AWARE_ENABLED'
          @rescomp << ' --define WXUSINGDLL'
          @extra_cflags << '-DISOLATION_AWARE_ENABLED'
          if @wx_version >= '3.3.0'
            @extra_cflags << '-D_UNICODE' << '-DUNICODE'
          end
        end
      end
      private :init_platform

    end

  end

end
