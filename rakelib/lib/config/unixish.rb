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
        !expand("which #{@wx_config} 2>/dev/null").chomp.empty?
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

        cfg = expand("#{@wx_config} #{debug_mode} --static=no #{option} 2>&1")

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

      def do_link(pkg)
        objs = pkg.all_obj_files.collect { |o| File.join('..', o) }.join(' ') + ' '
        depsh = pkg.dep_libnames.collect { |dl| "#{dl}.#{dll_ext}" }.join(' ')
        sh "cd lib && #{WXRuby3.config.ld} #{WXRuby3.config.ldflags(pkg.lib_target)} #{objs} #{depsh} " +
             "#{WXRuby3.config.libs} #{WXRuby3.config.link_output_flag}#{pkg.lib_target}"
      end

      private

      def wx_checkout
        check_git
        # clone wxWidgets GIT repository under ext_path
        chdir(ext_path) do
          if (rc = sh("git clone https://github.com/wxWidgets/wxWidgets.git"))
            chdir('wxWidgets') do
              tag = if @wx_version
                      "v#{@wx_version}"
                    else
                      expand('git tag').split("\n").select { |t| t.start_with?('v3.2') }.max
                    end
              # checkout the version we are building against
              rc = sh("git checkout #{tag}")
            end
          end
          unless rc
            STDERR.puts "ERROR: Failed to checkout wxWidgets."
            exit(1)
          end
        end
      end

      def wx_build
        # initialize submodules
        unless sh('git submodule update --init')
          STDERR.puts "ERROR: Failed to update wxWidgets submodules."
          exit(1)
        end
        # configure wxWidgets
        unless bash('./configure --prefix=`pwd`/install --disable-tests --without-subdirs --disable-debug_info')
          STDERR.puts "ERROR: Failed to configure wxWidgets."
          exit(1)
        end
        # make and install wxWidgets
        unless bash('make && make install')
          STDERR.puts "ERROR: Failed to build wxWidgets libraries."
          exit(1)
        end
      end

      def wx_generate_xml
        chdir(File.join(ext_path, 'wxWidgets', 'docs', 'doxygen')) do
          sh({ 'WX_SKIP_DOXYGEN_VERSION_CHECK' => '1' }, './regen.sh xml')
        end
      end

      def expand(cmd)
        STDERR.puts "> sh: #{cmd}" if verbose?
        s = super
        STDERR.puts "< #{s}" if verbose?
        s
      end

      # Allow specification of custom wxWidgets build (mostly useful for
      # static wxRuby3 builds)
      def get_wx_path
        get_config('with-wxwin') && get_cfg_string('wxwin').empty? ? File.join(ext_path, 'wxWidgets', 'install') : get_cfg_string('wxwin')
      end

      def get_wx_xml_path
        get_cfg_string('wxxml')
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
          @ruby_ldflags << ' -s' if @release_build # strip debug symbols for release build

          # maintain minimum compatibility with ABI 3.0.0
          @wx_abi_version = [ @wx_version, "3.0.0" ].min
          @wx_cppflags << " -DwxABI_VERSION=%s" % @wx_abi_version.tr(".", "0")
        end
      end
    end

  end

end
