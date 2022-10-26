#--------------------------------------------------------------------
# @file    unixish.rb
# @author  Martin Corino
#
# @brief   wxRuby3 buildtools configuration
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

module WXRuby3

  module Config

    # Common code for platforms that use wx-config (basically, everything
    # not MSW)
    module UnixLike

      private

      def sh(cmd)
        `#{cmd}`
      end

      # Allow specification of custom wxWidgets build (mostly useful for
      # static wxRuby3 builds)
      def get_wx_path
        ENV['WXWIN'] || ''
      end

      def get_wx_xml_path
        ENV['WXXML'] || ''
      end

      # Helper function that runs the wx-config command line program from
      # wxWidgets to determine suitable builds and build options. Passed an
      # option which corresponds to one of the command-line options to
      # wx-config, eg '--list' or '--libs'. See --help for that program.
      def wx_config(option)
        #
        if @release_build
          debug_mode = '--debug=no'
        elsif @debug_build
          debug_mode = '--debug=yes'
        else
          debug_mode = '' # go with default
        end

        if @static_build
          static_mode = '--static=yes'
        elsif @dynamic_build
          static_mode = '--static=no'
        else
          static_mode = ''
        end


        cfg = sh("#{@wx_config} #{debug_mode} #{static_mode} #{option} 2>&1")

        # Check status for errors
        unless $?.exitstatus.zero?
          if cfg =~ /Warning: No config found to match:([^\n]*)/
            raise "No suitable wxWidgets found for specified build options;\n" +
              "(#{$1.strip})"
          else
            raise "wx-config error:\n(#{cfg})"
          end
        end

        return cfg.strip
      end

      def init_unix_platform
        # Allow specification of custom wxWidgets build (mostly useful for
        # static wxRuby3 builds)
        @wx_path = get_wx_path

        @wx_xml_path = get_wx_xml_path

        @wx_config = @wx_path.empty? ? 'wx-config' : File.join(@wx_path, 'bin', 'wx-config')

        # First, if either debug/release or static/dynamic has been left
        # unspecified, find out what default build is available, and set that.
        unless @dynamic_build or @static_build
          if wx_config('--list') =~ /\ADefault config is ([\w.-]+)/
            available = $1
            if available =~ /static/
              @static_build  = true
            else
              @dynamic_build = true
            end
          end
        end

        unless @release_build or @debug_build
          if wx_config('--list') =~ /\ADefault config is ([\w.-]+)/
            available = $1
            if available =~ /debug/
              @debug_build  = true
            else
              @release_build = true
            end
          end
        end

        # Now actually run the program to fill in some variables
        @wx_version  = wx_config("--version")
        @wx_cppflags = wx_config("--cppflags")
        @cpp         = wx_config("--cxx")
        @ld          = wx_config("--ld")
        @wx_libs     = wx_config("--libs all")

        # remove all warning flags provided by Ruby config
        @ruby_cppflags = @ruby_cppflags.split(' ').select { |o| !o.start_with?('-W') }.join(' ')
        @ruby_cppflags << ' -Wall -Wextra -Wno-unused-parameter' # only keep these

        # maintain minimum compatibility with ABI 3.0.0
        version = [ @wx_version, "3.0.0" ].min
        @wx_cppflags << " -DwxABI_VERSION=%s" % version.tr(".", "0")

        # Find out where the wxWidgets setup.h file being used is located; this
        # will be used later in rakeconfigure.rb
        setup_inc_dir = @wx_cppflags[/^-I(\S+)/][2..-1]
        @wx_setup_h  = File.join(setup_inc_dir, 'wx', 'setup.h')

        # # Check for some optional components in wxWidgets: STC (Scintilla) and
        # # OpenGL; don't try and compile those classes if not present. Tests
        # # whether the library file exists.
        #
        # # Hold the actual --lib argument to be used for the final flags
        # libs_str = "--libs std"
        #
        # # Test for RichTextCtrl
        # if @dynamic_build
        #   if macosx?
        #     richtext_lib = @wx_libs[/\S+wx_mac\S+_richtext\S+/]
        #     if richtext_lib.nil? or ( richtext_lib !~ /^-l/ and not File.exists?(richtext_lib) )
        #       WxRubyFeatureInfo.exclude_module('RichTextCtrl')
        #       WxRubyFeatureInfo.exclude_module('RichTextEvent')
        #       WxRubyFeatureInfo.exclude_module('RichTextBuffer')
        #     else
        #       libs_str << ',richtext'
        #     end
        #   else
        #     richtext_lib = @wx_libs[/\S+wx_gtk\S+_richtext\S+/]
        #     if richtext_lib.nil?
        #       WxRubyFeatureInfo.exclude_module('RichTextCtrl')
        #       WxRubyFeatureInfo.exclude_module('RichTextEvent')
        #       WxRubyFeatureInfo.exclude_module('RichTextBuffer')
        #     else
        #       libs_str << ',richtext'
        #     end
        #   end
        # else
        #   richtext_lib = @wx_libs[/\S+libwx\S+_richtext\S+/]
        #   if richtext_lib.nil? or not File.exists?(richtext_lib)
        #     WxRubyFeatureInfo.exclude_module('RichTextCtrl')
        #     WxRubyFeatureInfo.exclude_module('RichTextEvent')
        #     WxRubyFeatureInfo.exclude_module('RichTextBuffer')
        #   else
        #     libs_str << ',richtext'
        #   end
        # end
        #
        # # Test for StyledTextCtrl (Scintilla)
        # if @dynamic_build
        #   if macosx?
        #     stc_lib = @wx_libs[/\S+wx_mac\S+_stc\S+/]
        #     if stc_lib.nil? or ( stc_lib !~ /^-l/ and not File.exists?(stc_lib) )
        #       WxRubyFeatureInfo.exclude_module('StyledTextCtrl')
        #       WxRubyFeatureInfo.exclude_module('StyledTextEvent')
        #     else
        #       libs_str << ',stc'
        #     end
        #   else
        #     stc_lib = @wx_libs[/\S+wx_gtk\S+_stc\S+/]
        #     if stc_lib.nil?
        #       WxRubyFeatureInfo.exclude_module('StyledTextCtrl')
        #       WxRubyFeatureInfo.exclude_module('StyledTextEvent')
        #     else
        #       libs_str << ',stc'
        #     end
        #   end
        # else
        #   stc_lib = @wx_libs[/\S+libwx\S+_stc\S+/]
        #   if stc_lib.nil? or not File.exists?(stc_lib)
        #     WxRubyFeatureInfo.exclude_module('StyledTextCtrl')
        #     WxRubyFeatureInfo.exclude_module('StyledTextEvent')
        #   else
        #     libs_str << ',stc'
        #   end
        # end
        #
        #
        # # Test for OpenGL
        # if @dynamic_build
        #   if macosx?
        #     gl_lib = @wx_libs[/\S+wx_mac\S+_gl\S+/]
        #     if gl_lib.nil? or ( gl_lib !~ /^-l/ and not File.exists?(gl_lib) )
        #       WxRubyFeatureInfo.exclude_module('GLCanvas')
        #     else
        #       libs_str << ',gl'
        #     end
        #   else
        #     gl_lib = @wx_libs[/\S+wx_gtk\S+_gl\S+/]
        #     if gl_lib.nil?
        #       WxRubyFeatureInfo.exclude_module('GLCanvas')
        #     else
        #       libs_str << ',gl'
        #     end
        #   end
        # else
        #   gl_lib = @wx_libs[/\S+libwx\S+_gl\S+/]
        #   if gl_lib.nil? or not File.exists?(gl_lib)
        #     WxRubyFeatureInfo.exclude_module('GLCanvas')
        #   else
        #     libs_str << ',gl'
        #   end
        # end
        #
        # # Bit ugly - if MEdiaCtrl is included, need to test if
        # # 1) we have a dynamic build (esp Linux, non-monolithic)
        # # 2) we have a non-monolithic static build (identified by linkdeps)
        # # PRobably not 100% correct but deals with the common cases..
        # if not WxRubyFeatureInfo.excluded_class?(@wx_setup_h, 'MediaCtrl')
        #   if @dynamic_build or
        #      wx_config('--linkdeps std') != wx_config('--linkdeps std,media') # 2)
        #     libs_str << ',media'
        #   end
        # end
        #
        # # Set the final list of libs to be used
        # @wx_libs = wx_config(libs_str)
      end
    end

  end

end
