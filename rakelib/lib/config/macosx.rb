# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 buildtools configuration
###

require_relative './unixish'
require_relative 'pkgman/macosx'

require 'pathname'

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
          protected :get_rpath_origin

          def patch_rpath(shlib, *rpath)
            # don't leave old rpath-s behind
            sh("install_name_tool -delete_rpath '@loader_path/../lib' #{shlib} 2>/dev/null", verbose: false) { |_,_| }
            # add deployment rpath-s
            sh("install_name_tool #{rpath.collect {|rp| "-add_rpath '#{rp}'"}.join(' ')} #{shlib} 2>/dev/null", verbose: false) { |_,_| }
            true
          end
          protected :patch_rpath

          # add deployment lookup paths for wxruby shared libraries
          # and make loadpath for initializer dylibs relative
          def update_shlib_loadpaths(shlib)
            # in case of a .bundle library
            if /\.bundle\Z/ =~ shlib
              # change the full path of the complementary initializer .dylib to a path relative to any rpath-s
              dylib = "lib#{File.basename(shlib, '.bundle')}.dylib"
              dylib_path = File.expand_path(File.join(Config.instance.dest_dir, dylib))
              sh("install_name_tool -change #{dylib_path} '@rpath/#{dylib}' #{shlib}")
            end
            super
          end

          # add Ruby library path for wxruby shared libraries
          def update_shlib_ruby_libpath(shlib)
            # fix lookup for the Ruby shared library
            # on MacOSX the Ruby library will be linked with it's full path from the **development** environment
            # which is no use after binary deployment so we change that to be relative to the executable's path
            # loading the shared libs (which is always going to be the Ruby exe)

            # get the development folder holding ruby lib
            ruby_libdir = Pathname.new(RB_CONFIG['libdir'])
            # determine the relative path to the lib directory from the executable dir
            # (this remains constant for any similar deployed Ruby for this platform)
            rel_ruby_libdir = ruby_libdir.relative_path_from(RB_CONFIG['bindir'])
            # get the Ruby library name used for linking
            ld_ruby_lib = (RB_CONFIG['LIBRUBYARG_SHARED'].split.find { |s| s =~ /^-lruby/ }).sub(/^-l/,'')
            # match the full shared library name that will be linked
            ruby_so = [RB_CONFIG['LIBRUBY_SO'], RB_CONFIG['LIBRUBY_SONAME'], *RB_CONFIG['LIBRUBY_ALIASES'].split].find do |soname|
              soname =~ /^lib#{ld_ruby_lib}\./
            end
            # form the full path of the shared Ruby library linked
            ruby_lib = File.join(ruby_libdir.to_s, RB_CONFIG['LIBRUBY_SO'])
            # change the full path to a path relative to the Ruby executable
            sh("install_name_tool -change #{ruby_lib} '@executable_path/#{rel_ruby_libdir.to_s}/#{ruby_so}' #{shlib}")
            true
          end

          # add deployment lookup paths for wxwidgets shared libraries
          def update_shlib_wxwin_libpaths(shlib, deplibs)
            if super
              changes = deplibs.collect { |dl| "-change '#{dl}' '@rpath/#{File.basename(dl)}'"}
              sh("install_name_tool #{changes.join(' ')} #{shlib} 2>/dev/null", verbose: false) { |_,_| }
              true
            else
              false
            end
          end

          def check_tool_pkgs
            pkg_deps = super
            # need g++ to build wxRuby3 extensions in any case
            pkg_deps << 'gcc' unless system('command -v g++>/dev/null')
            # need this to build anything (like wxRuby3 extensions itself)
            pkg_deps << 'xcode' unless system('command -v install_name_tool>/dev/null')
            pkg_deps
          end

          def install_prerequisites
            pkg_deps = check_tool_pkgs
            PkgManager.install(pkg_deps)
            []
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
            if features_set?('USE_MEDIACTRL')
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

          def do_shlib_link(pkg)
            objs = pkg.all_obj_files.collect { |o| File.join('..', o) }.join(' ') + ' '
            depsh = pkg.dep_libs.join(' ')
            ldsh = WXRuby3.config.ld.sub(/-bundle/, '')
            ldsh.sub!(/-dynamic/, '-dynamiclib')
            sh "cd lib && " +
                 "#{ldsh} #{WXRuby3.config.ldflags(pkg.lib_target)} #{objs} #{depsh} " +
                 "#{WXRuby3.config.libs} #{WXRuby3.config.link_output_flag}#{pkg.shlib_target}",
               fail_on_error: true
          end

          def do_link(pkg)
            sh "cd lib && " +
                 "#{WXRuby3.config.ld} #{WXRuby3.config.ldflags(pkg.lib_target)} #{File.join('..', pkg.init_obj_file)} " +
                    "-L. -l#{pkg.libname} " +
                    "#{WXRuby3.config.libs} #{WXRuby3.config.link_output_flag}#{pkg.lib_target}",
               fail_on_error: true
          end

          private

          def wx_configure
            wxw_ver = nil
            if WXRuby3.config.sysinfo.os.release >= '15'
              # try to detect wxWidgets version
              verfile = File.join(ext_path, 'wxWidgets', 'include', 'wx', 'version.h')
              if File.exist?(verfile)
                v_major = v_minor = v_release = nil
                File.foreach(verfile) do |line|
                  case line
                  when /\#define\s+wxMAJOR_VERSION\s+(\d+)/
                    v_major = $1.to_i
                  when /\#define\s+wxMINOR_VERSION\s+(\d+)/
                    v_minor = $1.to_i
                  when /\#define\s+wxRELEASE_NUMBER\s+(\d+)/
                    v_release = $1.to_i
                  end
                end
                wxw_ver = "#{v_major}.#{v_minor}.#{v_release}"
              end
            end
            if WXRuby3.config.sysinfo.os.release >= '15' && (wxw_ver.nil? || wxw_ver <= '3.2.6')
              # circumvent compilation problems on MacOS 15 or higher with older wxWidgets releases
              bash("./configure " +
                     "--disable-optimise --disable-sys-libs --without-liblzma --without-regex " +
                     "--prefix=`pwd`/install --disable-tests --without-subdirs --disable-debug_info " +
                     "CFLAGS=\"-Wno-unused-but-set-variable\"")
            else
              bash("./configure --with-macosx-version-min=#{WXRuby3.config.sysinfo.os.release}.0 " +
                     "--disable-optimise --disable-sys-libs --without-liblzma --without-regex " +
                     "--prefix=`pwd`/install --disable-tests --without-subdirs --disable-debug_info " +
                     "CFLAGS=\"-Wno-unused-but-set-variable\"")
            end
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
          # on Mac OSX this differs from the wxWidgets linking setup
          @ld = RB_CONFIG['LDSHAREDXX'] || 'g++ -std=gnu++14 -dynamic -bundle'
          @ld.sub!(/-std=gnu\+\+11/, '-std=gnu++14')

          @extra_cflags.concat %w[-Wno-unused-function -Wno-conversion-null -Wno-sometimes-uninitialized
                                  -Wno-overloaded-virtual -Wno-deprecated-copy]
          @extra_cflags << ' -Wno-deprecated-declarations' unless @no_deprecated

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
