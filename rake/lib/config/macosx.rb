#--------------------------------------------------------------------
# @file    macosx.rb
# @author  Martin Corino
#
# @brief   wxRuby3 buildtools configuration
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

require_relative './unixish'

module WXRuby3

  module Config

    # Platform-dependent compile settings for Mac OS X.
    # From wxRuby 2.0.2 onwards, assumes compiling on OS X 10.6, Snow
    # Leopard, for a target of i386 architecture on 10.5/10.6
    #
    # Will NOT build with the standard Apple (64-bit) ruby included with
    # 10.6. Requires a ruby with i386 architecture support.
    module Platform

      def self.included(base)
        base.include Config::UnixLike
      end

      def build_framework()
        base = "#{@dest_dir}/wxruby.framework"
        if (File.exists?(base))
          `rm -fr #{base}`
        end
        #
        # Create the directories
        #
        Dir.mkdir(base);
        Dir.mkdir("#{base}/Versions")
        Dir.mkdir("#{base}/Versions/A")
        Dir.mkdir("#{base}/Versions/A/Resources")

        #
        # Copy in the libraries
        #
        `cp #{@dest_dir}/wxruby #{base}/Versions/A/wxruby`
        create_info_plist(base)
        create_resources(base)
        #
        # Create the symlinks
        #
        File.symlink("Versions/A/wxruby","#{base}/wxruby")
        File.symlink("Versions/A/Resources","#{base}/Resources")
        File.symlink("Versions/A","#{base}/Current")

      end

      def create_info_plist(base)
        File.open("#{base}/Versions/A/Resources/Info.plist","w") do |fp|
          fp.puts <<INFOLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>English</string>
    <key>CFBundleIdentifier</key>
    <string>org.wxwidgets.wxruby.framework</string>
    <key>CFBundlePackageType</key>
    <string>FMWK</string>
    <key>CFBundleShortVersionString</key>
    <string>2.0.0</string>
    <key>CFBundleSignature</key>
    <string>????</string>
    <key>CFBundleName</key>
    <string>wxruby</string>
    <key>CFBundleVersion</key>
    <string>2.0.0</string>
    <key>CFBundleGetInfoString</key>
    <string>wxruby 2.0.0 (c) 2006 Kevin Smith, Nicreations</string>
    <key>CFBundleLongVersionString</key>
    <string>2.0.0, (c) 2006 Kevin Smith, Nicreations</string>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright 2006 Kevin Smith, Nicreations</string>
    <key>LSRequiresCarbon</key>
    <true/>
    </dict>
</plist>
INFOLIST
        end
      end
      private :create_info_plist

      def create_resources(base)
        cmd = `#{@wx_config} --rezflags`.strip
        `#{cmd} #{base}/Versions/A/Resources/wxruby.rsrc`
      end
      private :create_resources

      def init_platform
        init_unix_platform

        @cpp = "g++"
        @ld = "g++"

        @wx_libs.chomp!
        @wx_libs.gsub!(/-framework (Cocoa|WebKit)/, '')
        @wx_libs << ' -framework Foundation -framework Appkit'

        # Only build for i386 - wxWidgets 2.8 cannot be compiled in 64-bit
        @ruby_cppflags.sub!(/-arch x86_64/, '')
        @ruby_ldflags.sub!(/-arch x86_64/, '')

        # If release build, remove debugging info; if debug build, ensure
        # debugging info and remove optimisations
        if @release_build
          @ruby_cppflags.sub!(/-g/, '')
        elsif @debug_build
          @extra_cppflags << ' -g'
          @ruby_cppflags.sub!(/-Os/, '')
        end

        # Support for Mac OS X 10.5, assuming compile on 10.6
        @extra_cppflags = '-x objective-c++ -isysroot /Developer/SDKs/MacOSX10.5.sdk -mmacosx-version-min=10.5'
        @extra_ldflags = '-dynamic -bundle -flat_namespace -undefined suppress -isysroot /Developer/SDKs/MacOSX10.5.sdk -mmacosx-version-min=10.5'
      end
      private :init_platform

    end

  end

end
