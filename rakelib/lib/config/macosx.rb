###
# wxRuby3 buildtools configuration
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './unixish'

module WXRuby3

  module Config

    module Platform

      def self.included(base)
        base.class_eval do
          include Config::UnixLike
          # alias :base_ldflags :ldflags
          # def ldflags(target)
          #   "-Wl,-soname,#{File.basename(target)} #{base_ldflags(target)}"
          # end

          def debug_command(*args)
            args.unshift(FileUtils::RUBY)
            args.unshift('--')
            args.unshift('lldb')
            args.join(' ')
          end

          def check_rpath_patch
            # unless @rpath_patch
            #   if system('which patchelf > /dev/null 2>&1')
            #     @rpath_patch = 'patchelf --set-rpath'
            #   else
            #     STDERR.puts 'Installation of binary gem with-wxwin requires an installed version of either the patchelf utility.'
            #     return false
            #   end
            # end
            true
          end

          def patch_rpath(shlib, rpath)
            # if check_rpath_patch
            #   sh("#{@rpath_patch} '#{rpath}' #{shlib}", verbose: false)
            #   return true
            # end
            # false
            true
          end

          def get_wx_libs
            wx_libset = ::Set.new
            lib_list = wx_config("--libs all").split(' ')
            until lib_list.empty?
              s = lib_list.shift
              if s == '-framework'
                wx_libset << "#{s} #{lib_list.shift}"
              else
                wx_libset << s
              end
            end
            # some weird thing with this; at least sometimes '--libs all' will not output media library even if feature active
            if features_set?('wxUSE_MEDIACTRL')
              lib_list = wx_config("--libs media").split(' ')
              until lib_list.empty?
                s = lib_list.shift
                if s == '-framework'
                  wx_libset << "#{s} #{lib_list.shift}"
                else
                  wx_libset << s
                end
              end
            end
            wx_libset.collect { |s| s.dup }
          end

          def do_link(pkg)
            objs = pkg.all_obj_files.collect { |o| File.join('..', o) }.join(' ') + ' '
            sh "cd lib && #{WXRuby3.config.ld} #{WXRuby3.config.ldflags(pkg.lib_target)} #{objs} " +
                 "#{WXRuby3.config.libs} #{WXRuby3.config.link_output_flag}#{pkg.lib_target}"
          end
        end
      end

      def init_platform
        init_unix_platform

        @cpp.sub!(/-std=gnu\+\+11/, '-std=gnu++14')
        @ld.sub!(/-o\s*\Z/, '')

        @dll_pfx = 'lib'

        if @wx_version
          @extra_cflags.concat %w[-Wno-unused-function -Wno-conversion-null -Wno-sometimes-uninitialized -Wno-overloaded-virtual]
          @extra_cflags << ' -Wno-deprecated-declarations' unless @no_deprecated

          # create a .dylib binary
          @extra_ldflags << '-dynamic -bundle'

          unless @wx_path.empty?
            libdirs = @wx_libs.select {|s| s.start_with?('-L')}.collect {|s| s.sub(/^-L/,'')}
            @exec_env['DYLD_LIBRARY_PATH'] = "#{ENV['DYLD_LIBRARY_PATH']}:#{dest_dir}:#{libdirs.join(':')}"
          end
        end
      end
      private :init_platform

    end

  end

end
