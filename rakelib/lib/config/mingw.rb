###
# wxRuby3 buildtools configuration
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './unixish'

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
        base.include Config::UnixLike
        base.class_eval do

          attr_reader :rescomp

          alias :base_ldflags :ldflags
          def ldflags(target)
            "-Wl,-soname,#{File.basename(target)} #{base_ldflags(target)}"
          end

          def debug_command(*args)
            args.unshift(FileUtils::RUBY)
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

          private

          def sh(cmd)
            super("bash -c \"#{cmd}\"")
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
            nix_path(get_config(:wxwin))
          end

        end
      end

      def init_platform
        init_unix_platform

        if @wx_version
          # need to convert these to windows paths
          @wx_cppflags.gsub!(/^-I(\S+)|\s-I(\S+)/) { |s| " -I#{win_path($1 || $2)}" }
          @wx_libs.gsub!(/^-L(\S+)|\s-L(\S+)/) { |s| " -L#{win_path($1 || $2)}" }

          @extra_cflags = '-Wno-unused-function -Wno-conversion-null -Wno-maybe-uninitialized'
          @extra_cflags << ' -Wno-deprecated-declarations' unless @no_deprecated

          # create a .dll binary
          @extra_ldflags = '-shared'

          # Extra libraries that are required on Linux
          @extra_libs = ""
          libs = @wx_libs.split(' ')
          libs.collect! do | lib |
            if @static_build and lib =~ /lwx_/
              lib = "-Wl,-Bstatic #{lib} -Wl,-Bdynamic "
            end
            lib
          end

          @wx_libs = libs.join(' ')

          @ruby_ldflags.sub!(' $(DEFFILE)', '') # cleanup for older RubyInstaller versions
          @ruby_ldflags << " -L#{RbConfig::CONFIG['libdir']}"
          @ruby_ldflags.gsub!(/-s(\s|\Z)/, '') if @debug_build # do not strip debug symbols for debug build
          @ruby_cppflags << " #{RbConfig::CONFIG['debugflags']}" if @debug_build
          @ruby_cppflags.gsub!(/-O\d/, '-O0') if @debug_build # disable optimizations for debug build

          unless @wx_path.empty?
            exec_pfx = win_path(wx_config("--exec-prefix"))
            libdirs = [File.join(exec_pfx, 'bin')]
            libdirs << win_path(File.join(ENV['MSYSTEM_PREFIX'], 'bin'))
            @exec_env['RUBY_DLL_PATH'] = "#{ENV['RUBY_DLL_PATH']};#{libdirs.join(';')}"
          end

          @rescomp = wx_config('--rescomp').gsub(/--include-dir\s+(\S+)/) { |s| "--include-dir #{win_path($1)}" }
          @rescomp << " --include-dir #{File.join(Config.wxruby_root, 'art')}"
          @rescomp << ' --define __WXMSW__ --define wxUSE_DPI_AWARE_MANIFEST=2 --define wxUSE_RC_MANIFEST=1 --define ISOLATION_AWARE_ENABLED'
          @rescomp << ' --define WXUSINGDLL'
          @extra_cflags << ' -DISOLATION_AWARE_ENABLED'
        end
      end
      private :init_platform

    end

  end

end
