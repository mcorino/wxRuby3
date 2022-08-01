#--------------------------------------------------------------------
# @file    mswin.rb
# @author  Martin Corino
#
# @brief   wxRuby3 buildtools configuration
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

require_relative './windows'

module WXRuby3

  module Config

    module Platform

      def self.included(base)
        base.include Config::Windows
      end

      def find_in_path(basename)
        ENV['PATH'].split(';').each do | path |
          maybe = File.join(path, basename)
          return maybe if File.exists?(maybe)
        end
        raise "Cannot find #{basename} in PATH"
      end
      private :find_in_path

      def init_platform
        init_windows_platform

        # The name of the compiler and linker
        @cpp  = "cl.exe"
        @ld   = "link"
        @cpp_out_flag     = "/Fo"
        @link_output_flag = "/dll /out:"

        # Only static build is currently allowed on Windows; TODO
        if @dynamic_build
          raise "Dynamically-linked build is not allowed on Windows, use static"
        else
          @static_build = true
        end

        # Variants within wxWidgets directory layout are identified by these tags
        @wx_version = '3.0.0'
        @debug_postfix   = @debug_build ? 'd' : ''
        @unicode_postfix = @unicode_build ? 'u' : ''
        @postfix = @unicode_postfix + @debug_postfix

        # Some secondary directories in the wxWidgets layout
        @wx_incdir      = File.join("#{@wx_dir}", "include")
        @wx_libdir      = File.join("#{@wx_dir}", "lib", "vc_lib")
        @wx_setupincdir = File.join("#{@wx_dir}", "lib", "vc_lib", "msw#{@postfix}")

        @wx_setup_h  = File.join(@wx_setupincdir, 'wx', 'setup.h')


        # wxWidgets libraries that should be linked into wxRuby
        # odbc and db_table not required by wxruby
        windows_libs = %W|wxbase#{@wx_version}#{@postfix}
                          wxbase#{@wx_version}#{@postfix}_net
                          wxbase#{@wx_version}#{@postfix}_xml
                          wxmsw#{@wx_version}#{@postfix}_adv
                          wxmsw#{@wx_version}#{@postfix}_core
                          wxmsw#{@wx_version}#{@postfix}_html
                          wxmsw#{@wx_version}#{@postfix}_media
                          wxmsw#{@wx_version}#{@postfix}_xrc
                          wxmsw#{@wx_version}#{@postfix}_aui
                          wxmsw#{@wx_version}#{@postfix}_richtext
                          wxexpat#{@debug_postfix}
                          wxjpeg#{@debug_postfix}
                          wxpng#{@debug_postfix}
                          wxtiff#{@debug_postfix}
                          wxzlib#{@debug_postfix}
                          wxregex#{@postfix}|

        windows_libs.map! { | lib | File.join(@wx_libdir, "#{lib}.lib") }

        # Windows-specific routines for checking for supported features
        # Test for presence of StyledTextCtrl (scintilla) library; link it in if
        # present, skip that class if not
        scintilla_lib = File.join( @wx_libdir,
                                   "wxmsw#{@wx_version}#{@postfix}_stc.lib" )
        if File.exists?(scintilla_lib)
          windows_libs << scintilla_lib
        else
          WxRubyFeatureInfo.exclude_class('StyledTextCtrl')
          WxRubyFeatureInfo.exclude_class('StyledTextEvent')
        end

        # Test for presence of OpenGL library; link it in if
        # present, skip that class if not
        gl_lib = File.join( @wx_libdir, "wxmsw#{@wx_version}#{@postfix}_gl.lib" )
        if File.exists?(gl_lib)
          windows_libs << gl_lib
        else
          WxRubyFeatureInfo.exclude_class('GLCanvas')
          WxRubyFeatureInfo.exclude_class('GLContext')
        end

        # Glue them all together into an argument passed to the linker
        @wx_libs = windows_libs.join(' ')

        @wx_cppflags = "-I#{@wx_incdir} -D__WXMSW__ -I#{@wx_setupincdir}"
        @extra_cppflags = %W[ /GR /EHsc -DSTRICT -DWIN32 -D__WIN32__ -DWINVER=0x0400
                              -D_WINDOWS /D__WINDOWS__  /D__WIN95__].join(' ')

        if @debug_build
          @ruby_cppflags.gsub!(/-MD/," /MDd");
          @ruby_cppflags.gsub!(/-O[A-Za-z0-9-]*/, "/Od")
          @ruby_cppflags += " -Zi -D_DEBUG -D__WXDEBUG__ -DWXDEBUG=1 "
          @extra_ldflags += "/DEBUG"
        else
          @ruby_cppflags += " -DNDEBUG "
        end

        if @unicode_build
          @wx_cppflags += " -D_UNICODE -DUNICODE"
        end

        # Extra files for the linker - WINDOWS_SYS_LIBS are common in rakewindows.rb
        lib_ruby =   File.join(RbConfig::CONFIG['libdir'], RbConfig::CONFIG['LIBRUBY'])
        @extra_libs = @windows_sys_libs.map { | lib | "#{lib}.lib" }.join(" ")
        @extra_libs << " #{lib_ruby}"



        @extra_objs = "swig/wx.res"

        rule('.res' => '.rc') do | t |
            sh("rc -I#{@wx_incdir} #{t.prerequisites}")
        end

        # Redistribute and install VC8 runtime - not recommended
        directory 'temp'
        file 'temp' do
          cp 'lib/wxruby3.so.manifest', 'temp'
          cp find_in_path('msvcp80.dll'), 'temp'
          cp find_in_path('msvcr80.dll'), 'temp'
          File.open('temp/Rakefile', 'w') do | f |
            f.puts <<TEMP_RAKEFILE
# This is a temporary rakefile to install the Microsoft v8 runtime
require 'rbconfig'
task :default do
  mv 'msvcp80.dll', RbConfig::CONFIG['bindir']
  mv 'msvcr80.dll', RbConfig::CONFIG['bindir']
  ruby_manifest = File.join(RbConfig::CONFIG['bindir'], 'ruby.exe.manifest')
  if File.exists? ruby_manifest 
    mv ruby_manifest, ruby_manifest + ".old"
  end
  cp 'wxruby3.so.manifest', ruby_manifest
  rubyw_manifest = File.join(RbConfig::CONFIG['bindir'], 'rubyw.exe.manifest')
  if File.exists? rubyw_manifest 
    mv rubyw_manifest, rubyw_manifest + ".old"
  end
  cp 'wxruby3.so.manifest', rubyw_manifest
end
TEMP_RAKEFILE
          end
        end
      end
      private :init_platform

    end

  end

end
