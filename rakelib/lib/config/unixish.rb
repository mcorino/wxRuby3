###
# wxRuby3 buildtools configuration
# Copyright (c) M.J.N. Corino, The Netherlands
###

require 'set'

module WXRuby3

  module Config

    # Common code for platforms that use wx-config (basically, everything
    # not MSW)
    module UnixLike

      def check_wx_config
        !sh("which #{@wx_config} 2>/dev/null").chomp.empty?
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
        end

        cfg = sh("#{@wx_config} #{debug_mode} --static=no #{option} 2>&1")

        # Check status for errors
        unless $?.exitstatus.zero?
          if cfg =~ /Warning: No config found to match:([^\n]*)/
            STDERR.puts "ERROR: No suitable wxWidgets found for specified build options " +
                          "(#{$1.strip})"
          else
            STDERR.puts "ERROR: wx-config error (#{cfg})"
          end
          exit(1)
        end

        return cfg.strip
      end

      private

      def sh(cmd)
        STDERR.puts "> sh: #{cmd}" if verbose?
        s = `#{cmd}`
        STDERR.puts "< #{s}" if verbose?
        s
      end

      # Allow specification of custom wxWidgets build (mostly useful for
      # static wxRuby3 builds)
      def get_wx_path
        get_config('with-wxwin') ? File.join(ext_path, 'wxWidgets', 'install') : get_config('wxwin')
      end

      def get_wx_xml_path
        get_config(:wxxml)
      end

      def init_unix_platform
        # Allow specification of custom wxWidgets build (mostly useful for
        # static wxRuby3 builds)
        @wx_path = get_wx_path

        STDERR.puts "> wx_path = '#{@wx_path}'" if verbose?

        @wx_xml_path = get_wx_xml_path

        @wx_config = @wx_path.empty? ? 'wx-config' : File.join(@wx_path, 'bin', 'wx-config')

        if check_wx_config
          # Now actually run the program to fill in some variables
          @wx_version  = wx_config("--version")
          @wx_cppflags = wx_config("--cppflags")

          # Find out where the wxWidgets setup.h file being used is located
          setup_inc_dir = @wx_cppflags[/^-I(\S+)/][2..-1]
          @wx_setup_h  = File.join(setup_inc_dir, 'wx', 'setup.h')

          @cpp         = wx_config("--cxx")
          @ld          = wx_config("--ld")
          wx_libset = ::Set.new
          wx_libset.merge wx_config("--libs all").split(' ')
          # some weird thing with this; at least sometimes '--libs all' will not output media library even if feature active
          if features_set?('wxUSE_MEDIACTRL')
            wx_libset.merge wx_config("--libs media").split(' ')
          end
          @wx_libs = wx_libset.to_a.join(' ')

          # remove all warning flags provided by Ruby config
          @ruby_cppflags = @ruby_cppflags.split(' ').select { |o| !o.start_with?('-W') }.join(' ')
          @ruby_cppflags << ' -Wall -Wextra -Wno-unused-parameter' # only keep these

          # maintain minimum compatibility with ABI 3.0.0
          @wx_abi_version = [ @wx_version, "3.0.0" ].min
          @wx_cppflags << " -DwxABI_VERSION=%s" % @wx_abi_version.tr(".", "0")
        end
      end
    end

  end

end
