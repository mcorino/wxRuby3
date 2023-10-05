# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 buildtools configuration
###

require_relative './unixish'

module WXRuby3

  module Config

    module Platform

      def self.included(base)
        base.class_eval do
          include Config::UnixLike

          def debug_command(*args)
            args.unshift(FileUtils::RUBY)
            args.unshift('--')
            args.unshift('lldb')
            args.join(' ')
          end

          def dll_mask
            "{#{dll_ext},dylib}"
          end

          def get_rpath_origin
            "@loader_path"
          end

          def check_rpath_patch
            # no need to check anything; install_name_tool is part of XCode cmdline tools
            # and without these we couldn't build anything
            true
          end

          def patch_rpath(shlib, *rpath)
            # don't leave old rpath-s behind
            sh("install_name_tool -delete_rpath '@loader_path/../lib' #{shlib} 2>/dev/null", verbose: false) { |_,_| }
            # add deployment rpath-s
            sh("install_name_tool #{rpath.collect {|rp| "-add_rpath '#{rp}'"}.join(' ')} #{shlib} 2>/dev/null", verbose: false) { |_,_| }
            true
          end

          def update_shlib_loadpaths(shlib, deplibs)
            changes = deplibs.collect { |dl| "-change '#{dl}' '@rpath/#{File.basename(dl)}'"}
            sh("install_name_tool #{changes.join(' ')} #{shlib} 2>/dev/null", verbose: false) { |_,_| }
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

          private

          def wx_configure
            bash('./configure --disable-optimise --disable-sys-libs --without-liblzma --prefix=`pwd`/install --disable-tests --without-subdirs --disable-debug_info CFLAGS="-Wno-unused-but-set-variable"')
          end

          def wx_make
            bash('make -j$(sysctl -n hw.logicalcpu) && make install')
          end
        end
      end

      def init_platform
        init_unix_platform

        @dll_pfx = 'lib'

        if @wx_version
          @cpp.sub!(/-std=gnu\+\+11/, '-std=gnu++14')
          @ld.sub!(/-o\s*\Z/, '')

          @extra_cflags.concat %w[-Wno-unused-function -Wno-conversion-null -Wno-sometimes-uninitialized
                                  -Wno-overloaded-virtual -Wno-deprecated-copy]
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
