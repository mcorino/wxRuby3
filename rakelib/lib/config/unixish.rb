# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 buildtools configuration
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
             "#{WXRuby3.config.libs} #{WXRuby3.config.link_output_flag}#{pkg.lib_target}",
           fail_on_error: true
      end

      def check_tool_pkgs
        pkg_deps = super
        pkg_deps << 'doxygen' unless system('command -v doxygen>/dev/null')
        pkg_deps << 'swig' unless system('command -v swig>/dev/null')
        pkg_deps
      end

      def get_rpath_origin
        "$ORIGIN"
      end

      def expand(cmd)
        STDERR.puts "> sh: #{cmd}" if verbose?
        s = super
        STDERR.puts "< #{s}" if verbose?
        s
      end

      def download_file(url, dest)
        sh("curl -L #{url} --output #{dest}")
      end

      private

      def wx_checkout
        $stdout.print 'Checking out wxWidgets...' if run_silent?
        # clone wxWidgets GIT repository under ext_path
        chdir(ext_path) do
          if (rc = sh("#{get_cfg_string('git')} clone https://github.com/wxWidgets/wxWidgets.git"))
            chdir('wxWidgets') do
              tag = if @wx_version
                      "v#{@wx_version}"
                    else
                      expand("#{get_cfg_string('git')} tag").split("\n").select { |t| (/\Av3\.(\d+)/ =~ t) && $1.to_i >= 2  }.max
                    end
              # checkout the version we are building against
              rc = sh("#{get_cfg_string('git')} checkout #{tag}")
            end
          end
          if rc
            $stdout.puts 'done!' if run_silent?
          else
            $stderr.puts "ERROR: Failed to checkout wxWidgets."
            exit(1)
          end
        end
      end

      def wx_configure
        bash('./configure --prefix=`pwd`/install --disable-tests --without-subdirs --disable-debug_info')
      end

      def wx_make
        bash('make -j$(nproc) && make install')
      end

      def wx_build
        $stdout.print 'Configuring wxWidgets...' if run_silent?
        # initialize submodules
        unless sh("#{get_cfg_string('git')} submodule update --init")
          $stderr.puts "ERROR: Failed to update wxWidgets submodules."
          exit(1)
        end
        # configure wxWidgets
        unless wx_configure
          $stderr.puts "ERROR: Failed to configure wxWidgets."
          exit(1)
        end
        $stdout.puts 'done!' if run_silent?
        $stdout.print 'Building wxWidgets...' if run_silent?
        # make and install wxWidgets
        unless wx_make
          $stderr.puts "ERROR: Failed to build wxWidgets libraries."
          exit(1)
        end
        $stdout.puts 'done!' if run_silent?
      end

      def wx_generate_xml
        chdir(File.join(ext_path, 'wxWidgets', 'docs', 'doxygen')) do
          unless sh({ 'DOXYGEN' => get_cfg_string("doxygen"),  'WX_SKIP_DOXYGEN_VERSION_CHECK' => '1' }, './regen.sh xml')
            $stderr.puts 'ERROR: Failed to generate wxWidgets XML API specifications for parsing by wxRuby3.'
            exit(1)
          end
        end
      end

      # Allow specification of custom wxWidgets build (mostly useful for
      # static wxRuby3 builds)
      def get_wx_path
        get_config('with-wxwin') && get_cfg_string('wxwin').empty? ? File.join(ext_path, 'wxWidgets', 'install') : get_cfg_string('wxwin')
      end

      def get_wx_xml_path
        get_cfg_string('wxxml')
      end

      def get_wx_libs
        wx_libset = ::Set.new
        wx_libset.merge wx_config("--libs all").split(' ')
        # some weird thing with this; at least sometimes '--libs all' will not output media library even if feature active
        if features_set?('USE_MEDIACTRL')
          wx_libset.merge wx_config("--libs media").split(' ')
        end
        wx_libset.collect { |s| s.dup }
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
          @wx_version  = wx_config('--version')
          @wx_port = case wx_config('--selected-config')
                     when /\Agtk/
                       :wxgtk
                     when /\Aqt/
                       :wxqt
                     when /\Ax11/
                       :wxx11
                     when /\Amotif/
                       :wxmotif
                     when /\Amsw/
                       :wxmsw
                     when /\Aosx/
                       :wxosx
                     else
                       nil
                     end
          @wx_cppflags = wx_config('--cppflags').split(' ')

          # Find out where the wxWidgets setup.h file being used is located
          setup_inc_dir = @wx_cppflags.find { |flag| flag =~ /^-I\S+/ }[2..-1]
          @wx_setup_h  = File.join(setup_inc_dir, 'wx', 'setup.h')

          @cpp         = wx_config("--cxx")
          @ld          = wx_config("--ld")
          @wx_libs     = get_wx_libs

          # remove all warning flags provided by Ruby config
          @ruby_cppflags = @ruby_cppflags.collect { |flags| flags.split(' ') }.flatten.
            select { |o| !o.start_with?('-W') || o.start_with?('-Wl,') }
          @ruby_cppflags.concat %w[-Wall -Wextra -Wno-unused-parameter]   # only keep these
          # add include flags
          @ruby_cppflags.concat ['-I.', *@ruby_includes.collect { |inc| "-I#{inc}" }]
          @ruby_ldflags << "-Wl,-rpath,'#{get_rpath_origin}/../lib'"      # add default rpath
          @ruby_libs <<  "-L#{RB_CONFIG['libdir']}"                       # add ruby lib dir
          # add ruby defined shared ruby lib(s); not any other flags
          @ruby_libs.concat RB_CONFIG['LIBRUBYARG_SHARED'].split(' ').select { |s| s.start_with?('-l')}

          # maintain minimum compatibility with ABI 3.0.0
          @wx_abi_version = [ @wx_version, "3.0.0" ].min
          @wx_cppflags << "-DwxABI_VERSION=%s" % @wx_abi_version.tr(".", "0")
        end
      end
    end

  end

end
