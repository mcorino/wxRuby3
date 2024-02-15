# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 buildtools configuration
###

require 'rbconfig'
require 'fileutils'
require 'json'
require 'open3'
require 'monitor'

module FileUtils
  # add convenience methods
  def rmdir_if(list, **kwargs)
    list = fu_list(list).select { |path| File.exist?(path) }
    rmdir(list, **kwargs) unless list.empty?
  end
  def rm_if(list, **kwargs)
    list = fu_list(list).select { |path| File.exist?(path) }
    rm_f(list, **kwargs) unless list.empty?
  end
end

module WXRuby3
  ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))

  if defined? ::RbConfig
    RB_CONFIG = ::RbConfig::CONFIG
  else
    RB_CONFIG = ::Config::CONFIG
  end unless defined? RB_CONFIG

  CFG_KEYS = %w[prefix
                bindir
                libdir
                datadir
                mandir
                sysconfdir
                localstatedir
                libruby
                librubyver
                librubyverarch
                siteruby
                siterubyver
                siterubyverarch
                rbdir
                sodir]

  RB_DEFAULTS = %w[bindir
                   libdir
                   datadir
                   mandir
                   sysconfdir
                   localstatedir]

  CONFIG = {
    'libruby' => File.join(RB_CONFIG['libdir'], 'ruby'),
    'librubyver' => RB_CONFIG['rubylibdir'],
    'librubyverarch' => RB_CONFIG['archdir'],
    'siteruby' => RB_CONFIG['sitedir'],
    'siterubyver' => RB_CONFIG['sitelibdir'],
    'siterubyverarch' => RB_CONFIG['sitearchdir'],
    'rbdir' => '$siterubyver',
    'sodir' => '$siterubyverarch',
  }

  CFG_KEYS.concat(%w{wxwin wxxml wxwininstdir with-wxwin with-debug swig doxygen})
  CONFIG.merge!({
                  'wxwin' => ENV['WXWIN'] || '',
                  'wxxml' => ENV['WXXML'] || '',
                  'wxwininstdir' => '',
                  'with-wxwin' => !!ENV['WITH_WXWIN'],
                  'with-debug' => ((ENV['WXRUBY_DEBUG'] || '') == '1'),
                  'swig' => ENV['WXRUBY_SWIG'] || 'swig',
                  'doxygen' => ENV['WXRUBY_DOXYGEN'] || 'doxygen',
                  'git' => ENV['WXRUBY_GIT'] || 'git'
                })
  CONFIG['autoinstall'] = (ENV['WXRUBY_AUTOINSTALL'] != '0') if ENV['WXRUBY_AUTOINSTALL']
  BUILD_CFG = '.wxconfig'

  # Ruby 2.5 is the minimum version for wxRuby3
  __rb_ver = RUBY_VERSION.split('.').collect {|v| v.to_i}
  if (__rb_major = __rb_ver.shift) < 2 || (__rb_major == 2 && __rb_ver.shift < 5)
    $stderr.puts 'ERROR: wxRuby3 requires Ruby >= 2.5.0!'
    exit(1)
  end

  # Pure-ruby lib files
  ALL_RUBY_LIB_FILES = FileList[ 'lib/**/*.rb' ]

  # The version file
  VERSION_FILE = File.join(ROOT,'lib', 'wx', 'version.rb')

  # Setting the version via an environment variable
  if ENV['WXRUBY_VERSION']
    WXRUBY_VERSION = ENV['WXRUBY_VERSION']
    File.open(VERSION_FILE, 'w') do | version_file |
      version_file.puts "module Wx"
      version_file.puts "  WXRUBY_VERSION    = '#{WXRUBY_VERSION}#{ENV['WXRUBY_RELEASE_TYPE'] || ''}'"
      version_file.puts "end"
    end
    # Try loading the existing version file
  elsif File.exist?(VERSION_FILE)
    require VERSION_FILE
    WXRUBY_VERSION = Wx::WXRUBY_VERSION
    # Leave version undefined
  else
    WXRUBY_VERSION = ''
  end

  WXWIN_MINIMUM = '3.2.0'

  module Config

    def self.command_to_s(*cmd)
      txt = if ::Hash === cmd.first
              cmd = cmd.dup
              env = cmd.shift
              env.collect { |k, v| "#{k}=#{v}" }.join(' ') << ' '
            else
              ''
            end
      txt << cmd.join(' ')
    end

    def run_silent?
      !!ENV['WXRUBY_RUN_SILENT']
    end

    def silent_log_name
      ENV['WXRUBY_RUN_SILENT'] || 'silent_run.log'
    end

    def log_progress(msg)
      run_silent? ? silent_runner.log(msg) : $stdout.puts(msg)
    end

    class SilentRunner < Monitor

      PROGRESS_CH = '.|/-\\|/-\\|'

      def initialize
        super
        @cout = 0
        @incremental = false
      end

      def incremental(f=true)
        synchronize do
          @cout = 0
          @incremental = !!f
        end
      end

      def run(*cmd, **kwargs)
        synchronize do
          @cout = 0 unless @incremental
        end
        output = nil
        verbose = kwargs.delete(:verbose)
        capture = kwargs.delete(:capture)
        if (Config.instance.verbose? && verbose != false) || !capture
          txt = Config.command_to_s(*cmd)
          if Config.instance.verbose? && verbose != false
            $stdout.puts txt
          end
          if !capture
            silent_log { |f| f.puts txt }
          end
        end
        if capture
          if capture == :out || capture == :no_err
            kwargs[:err] = (Config.instance.windows? ? 'NULL' : '/dev/null') if capture == :no_err
            Open3.popen2(*cmd, **kwargs) do |_ins, os, tw|
              output = silent_runner(os)
              tw.value
            end
          else
            Open3.popen2e(*cmd, **kwargs) do |_ins, eos, tw|
              output = silent_runner(eos)
              tw.value
            end
          end
          output.join
        else
          rc = silent_log do |fout|
            Open3.popen2e(*cmd, **kwargs) do |_ins, eos, tw|
              silent_runner(eos, fout)
              v = tw.value.exitstatus
              fout.puts "-> Exit code: #{v}"
              v
            end
          end
          rc
        end
      end

      def log(msg)
        silent_log { |f| f.puts(msg) }
      end

      private

      def silent_runner(os, output=[])
        synchronize do
          if @incremental
            @cout += 1
            $stdout.print "#{PROGRESS_CH[@cout%10]}\b"
            $stdout.flush
          end
        end
        os.each do |ln|
          synchronize do
            unless @incremental
              @cout += 1
              $stdout.print "#{PROGRESS_CH[@cout%10]}\b"
              $stdout.flush
            end
            output << ln
          end
        end
        output
      end

      def silent_log(&block)
        File.open(Config.instance.silent_log_name, 'a') do |fout|
          block.call(fout)
        end
      end

    end

    def silent_runner
      @silent_runner ||= SilentRunner.new
    end
    private :silent_runner

    def do_silent_run(*cmd, **kwargs)
      silent_runner.run(*cmd, **kwargs)
    end
    private :do_silent_run

    def do_silent_run_step(*cmd, **kwargs)
      silent_runner.run_one(*cmd, **kwargs)
    end
    private :do_silent_run_step

    def set_silent_run_incremental
      silent_runner.incremental
    end

    def set_silent_run_batched
      silent_runner.incremental(false)
    end

    def do_run(*cmd, capture: nil)
      output = nil
      if run_silent?
        output = do_silent_run(exec_env, *cmd, capture: capture)
        unless capture
          fail "Command failed with status (#{rc}): #{Config.command_to_s(*cmd)}" unless output == 0
        end
      else
        if capture
          env_bup = exec_env.keys.inject({}) do |h, ev|
            h[ev] = ENV[ev] ? ENV[ev].dup : nil
            h
          end
          case capture
          when :out
            # default
          when :no_err
            # redirect stderr to null sink
            cmd << '2> ' << (windows? ? 'NULL' : '/dev/null')
          when :err, :all
            cmd << '2>&1'
          end
          begin
            # setup ENV for child execution
            ENV.update(Config.instance.exec_env)
            output = `#{cmd.join(' ')}`
          ensure
            # restore ENV
            env_bup.each_pair do |k,v|
              if v
                ENV[k] = v
              else
                ENV.delete(k)
              end
            end
          end
        else
          Rake.sh(exec_env, *cmd, verbose: verbose?)
        end
      end
      output
    end
    private :do_run

    def make_ruby_cmd(*cmd, verbose: true)
      [
        FileUtils::RUBY,
        '-I', rb_lib_path,
        (verbose && verbose? ? '-v' : nil),
        *cmd.flatten
      ].compact
    end
    private :make_ruby_cmd

    def execute(*cmd)
      do_run(*cmd.flatten)
    end

    def run(*cmd, capture: nil, verbose: true)
      do_run(*make_ruby_cmd(cmd, verbose: verbose), capture: capture)
    end

    def debug_command(*args)
      raise "Do not know how to debug for platform #{platform}"
    end

    def debug(*args, **options)
      args.unshift("-I#{File.join(Config.wxruby_root, 'lib')}")
      Rake.sh(exec_env, debug_command(*args), **options)
    end

    def respawn_rake(argv = ARGV)
      Kernel.exec($0, *argv)
    end

    def expand(cmd)
      `#{cmd}`
    end

    def sh(*cmd, fail_on_error: false, **kwargs)
      if run_silent?
        rc = do_silent_run(*cmd, **kwargs)
        fail "Command failed with status (#{rc}): #{Config.command_to_s(*cmd)}" if fail_on_error && rc != 0
        rc == 0
      elsif fail_on_error
        Rake.sh(*cmd, **kwargs)
      else
        Rake.sh(*cmd, **kwargs) { |ok,_| !!ok }
      end
    end
    alias :bash :sh

    def test(*tests, **options)
      errors = 0
      excludes = (ENV['WXRUBY_TEST_EXCLUDE'] || '').split(':')
      tests = Dir.glob(File.join(Config.instance.test_dir, '*.rb')) if tests.empty?
      tests.each do |test|
        unless excludes.include?(File.basename(test, '.*'))
          unless File.exist?(test)
            test = File.join(Config.instance.test_dir, test)
            test = Dir.glob(test+'.rb').shift || test unless File.exist?(test)
          end
          Rake.sh(Config.instance.exec_env, *make_ruby_cmd(test)) { |ok,status| errors += 1 unless ok }
        end
      end
      fail "ERRORS: ##{errors} test scripts failed." if errors>0
    end

    def irb(**options)
      irb_cmd = File.join(File.dirname(FileUtils::RUBY), 'irb')
      Rake.sh(Config.instance.exec_env, *make_ruby_cmd('-x', irb_cmd), **options)
    end

    def check_wx_config
      false
    end

    def wx_config(_option)
      nil
    end

    def check_tool_pkgs
      []
    end

    def download_file(_url, _dest)
      raise NoMethodError
    end

    def install_prerequisites
      pkg_deps = check_tool_pkgs
      if get_config('autoinstall') == false
        $stderr.puts <<~__ERROR_TXT
          ERROR: This system lacks installed versions of the following required software packages:
            #{pkg_deps.join(', ')}
            
            Install these packages and try again.
        __ERROR_TXT
        exit(1)
      end
      pkg_deps
    end

    # only called after src gem build
    def cleanup_prerequisites
      # noop
    end

    def wants_autoinstall?
      flag = get_config('autoinstall')
      if flag.nil?
        $stdout.puts <<~__Q_TEXT

          [ --- ATTENTION! --- ]
          wxRuby3 requires some software packages to be installed before being able to continue building.
          If you like these can be automatically installed next (if you are building the source gem the
          software will be removed again after building finishes).
          Do you want to have the required software installed now? [yN] : 
        __Q_TEXT
        answer = $stdin.gets(chomp: true).strip
        while !answer.empty? && !%w[Y y N n].include?(answer)
          $stdout.puts 'Please answer Y/y or N/n [Yn] : '
          answer = $stdin.gets(chomp: true).strip
        end
        flag = %w[Y y].include?(answer)
      end
      flag
    end

    def get_config(key)
      Config.get_config(key)
    end

    def get_cfg_string(key)
      Config.get_cfg_string(key)
    end

    def set_config(key, val)
      Config.set_config(key, val)
    end

    def dll_mask
      "#{dll_ext}*"
    end

    def do_link(_pkg)
    end

    def get_rpath_origin
      ''
    end

    def check_rpath_patch
      true
    end

    def patch_rpath(_shlib, *)
      true
    end

    def update_wxruby_shlib_loadpaths(_shlib)
      true
    end

    def update_wxwin_shlib_loadpaths(_shlib, _deplibs)
      true
    end

    class AnyOf
      def initialize(*features)
        @features = features
      end
      attr_reader :features

      def hash
        @features.hash
      end

      def eql?(other)
        self.class === other && @features.eql?(other.features)
      end
    end

    class << self

      def rb_version
        @rb_version ||= RUBY_VERSION.split('.').collect {|n| n.to_i}
      end

      def rb_ver_major
        rb_version[0]
      end

      def rb_ver_minor
        rb_version[1]
      end

      def rb_ver_release
        rb_version[2]
      end

      def build_cfg
        File.join(WXRuby3::ROOT, WXRuby3::BUILD_CFG)
      end

      def save
        File.open(build_cfg, 'w') do |f|
          f << JSON.pretty_generate(WXRuby3::CONFIG)
        end
      end

      def load
        if File.file?(build_cfg)
          File.open(build_cfg, 'r') do |f|
            WXRuby3::CONFIG.merge!(JSON.load(f.read))
          end
        end
      end

      def wxruby_root
        WXRuby3::ROOT
      end

      def platform
        case RUBY_PLATFORM
        when /mingw/
          :mingw
        when /cygwin/
          :cygwin
        when /netbsd/
          :netbsd
        when /darwin/
          :macosx
        when /linux/
          :linux
        else
          :unknown
        end
      end

      def create
        load # load the build config (if any)
        klass = Class.new do
          include FileUtils

          include Config

          def initialize
            @ruby_exe = RB_CONFIG["ruby_install_name"]

            @extmk = /extmk\.rb/ =~ $0
            @platform = Config.platform
            require File.join(File.dirname(__FILE__), 'config', @platform.to_s)
            self.class.include(WXRuby3::Config::Platform)

            init # initialize settings
          end

          attr_reader :ruby_exe, :extmk, :platform, :helper_modules, :helper_inits, :include_modules, :verbosity
          attr_reader :release_build, :debug_build, :verbose_debug, :no_deprecate
          attr_reader :ruby_cppflags, :ruby_ldflags, :ruby_libs, :extra_cflags, :extra_cppflags, :extra_ldflags,
                      :extra_libs, :cpp_out_flag, :link_output_flag, :obj_ext, :dll_ext,
                      :cxxflags, :libs, :cpp, :ld, :verbose_flag
          attr_reader :wx_port, :wx_path, :wx_cppflags, :wx_libs, :wx_setup_h, :wx_xml_path
          attr_reader :swig_major, :swig_dir, :swig_path, :src_dir, :src_path, :src_gen_dir, :src_gen_path, :obj_dir, :obj_path,
                      :rake_deps_dir, :rake_deps_path, :dest_dir, :test_dir, :classes_dir, :classes_path,
                      :common_dir, :common_path, :interface_dir, :interface_path,
                      :ext_dir, :ext_path, :wxruby_dir, :wxruby_path, :exec_env
          attr_reader :rb_lib_dir, :rb_lib_path, :rb_events_dir, :rb_events_path,
                      :rb_doc_dir, :rb_doc_path, :rb_docgen_dir, :rb_docgen_path

          # (re-)initialize settings
          def init
            # STANDARD DIRECTORIES
            @ext_dir = 'ext'
            @ext_path = File.join(Config.wxruby_root, @ext_dir)
            @wxruby_dir = File.join(@ext_dir, 'wxruby3')
            @wxruby_path = File.join(@ext_path, 'wxruby3')
            @swig_dir = File.join(@wxruby_dir,'swig')
            @swig_path = File.join(Config.wxruby_root, @swig_dir)
            @rake_deps_dir = File.join('rakelib', 'deps')
            @rake_deps_path = File.join(Config.wxruby_root, @rake_deps_dir)
            @src_dir = File.join(@wxruby_dir,'src')
            @src_path = File.join(Config.wxruby_root, @src_dir)
            @src_gen_dir = File.join(@src_dir, '.generate')
            @src_gen_path = File.join(Config.wxruby_root, @src_gen_dir)
            @obj_dir = File.join(@wxruby_dir,'obj')
            @obj_path = File.join(Config.wxruby_root, @obj_dir)
            @dest_dir = File.join(Config.wxruby_root, 'lib')
            @test_dir = File.join(Config.wxruby_root, 'tests')
            @classes_dir = File.join(@swig_dir, 'classes')
            @classes_path = File.join(Config.wxruby_root, @classes_dir)
            @common_dir = File.join(@classes_dir, 'common')
            @common_path = File.join(Config.wxruby_root, @common_dir)
            @interface_dir = File.join(@classes_dir, 'include')
            @interface_path = File.join(Config.wxruby_root, @interface_dir)
            @rb_lib_dir = 'lib'
            @rb_lib_path = File.join(Config.wxruby_root, @rb_lib_dir)
            @rb_doc_dir = File.join(@rb_lib_dir, 'wx', 'doc')
            @rb_doc_path = File.join(Config.wxruby_root, @rb_doc_dir)
            @rb_docgen_dir = File.join(@rb_doc_dir, 'gen')
            @rb_docgen_path = File.join(Config.wxruby_root, @rb_docgen_dir)

            # Extra swig helper files to be built
            @helper_modules = %w|RubyStockObjects|
              # if macosx?
              #                   %w|RubyStockObjects Mac|
              #                 else
              #                   %w|RubyStockObjects|
              #                 end
            # helper to initialize on startup (stock objects can only be initialized after App creation)
            @helper_inits = @helper_modules - %w|RubyStockObjects|

            # included swig specfiles not needing standalone processing
            @include_modules =
              %w|common.i typedefs.i typemap.i mark_free_impl.i memory_management.i shared/*.i|.collect do |glob|
                Dir.glob(File.join(@swig_dir, glob))
              end.flatten


            @debug_build   = WXRuby3::CONFIG['with-debug']
            @release_build = !@debug_build
            @verbosity     = ENV['WXRUBY_VERBOSE'] ? (ENV['WXRUBY_VERBOSE'] || '1').to_i : 0

            @dynamic_build = !!ENV['WXRUBY_DYNAMIC']
            @static_build  = !!ENV['WXRUBY_STATIC']

            @no_deprecate = !(!!ENV['WX_KEEP_DEPRECATE'])


            @ruby_includes = [ RB_CONFIG["rubyhdrdir"],
                               RB_CONFIG["sitehdrdir"],
                               RB_CONFIG["vendorhdrdir"],
                               RB_CONFIG['rubyarchhdrdir'] ?
                                 RB_CONFIG['rubyarchhdrdir'] :
                                 File.join(RB_CONFIG["rubyhdrdir"], RB_CONFIG['arch'])
                              ].compact
            @ruby_includes << File.join(@wxruby_path, 'include')

            @ruby_cppflags    = [RB_CONFIG["CFLAGS"]].compact
            @ruby_ldflags     = [RB_CONFIG['LDFLAGS'], RB_CONFIG['DLDFLAGS'], RB_CONFIG['ARCHFLAG']].compact
            @ruby_libs        = []
            @extra_cppflags   = ['-DSWIG_TYPE_TABLE=wxruby3']
            @extra_cflags     = []
            @extra_ldflags    = []
            @extra_libs       = []
            @cpp_out_flag     =  '-o '
            @link_output_flag = '-o '

            @obj_ext          = RB_CONFIG["OBJEXT"]
            @dll_ext          = RB_CONFIG['DLEXT']

            # Exclude certian classes from being built, even if they are present
            # in the configuration of wxWidgets.
            if ENV['WXRUBY_EXCLUDED']
              ENV['WXRUBY_EXCLUDED'].split(",").each { |classname| exclude_module(classname) }
            end

            @exec_env         = {}

            # platform specific initialization
            init_platform

            if @wx_xml_path.empty?
              @wx_xml_path = File.join(@ext_path, 'wxWidgets', 'docs', 'doxygen', 'out', 'xml')
            end

            @verbose_flag = ''
            if @debug_build
              @verbose_flag << '-D__WXRB_DEBUG__=1'
            end

            # SIXTH: Putting it all together

            # Flags to be passed to the C++ compiler
            @cxxflags = [@wx_cppflags, @ruby_cppflags, @extra_cflags, @extra_cppflags ].flatten.join(' ')

            # Flags to be passed to the linker
            @ldflags  = [ @ruby_ldflags, @extra_ldflags ].flatten.join(' ')

            # Libraries that the linker should build
            @libs     = [ @wx_libs, @ruby_libs, @extra_libs ].flatten.join(' ')
          end

          def report
            if @debug_build
              log_progress("Enabled DEBUG build")
            else
              log_progress("Enabled RELEASE build")
            end
          end

          def verbose?
            @verbosity>0
          end

          def is_configured?
            File.file?(File.join(WXRuby3::ROOT, WXRuby3::BUILD_CFG))
          end

          def is_bootstrapped?
            is_configured? && File.directory?(wx_xml_path)
          end

          def with_wxwin?
            get_config('with-wxwin')
          end

          def wx_version
            @wx_version || ''
          end

          def wx_abi_version
            @wx_abi_version || ''
          end

          def cygwin?
            @platform == :cygwin
          end

          def mingw?
            @platform == :mingw
          end

          def netbsd?
            @platform == :netbsd
          end

          def macosx?
            @platform == :macosx
          end

          def linux?
            @platform == :linux
          end

          def windows?
            mingw? || cygwin?
          end

          def ldflags(_target)
            @ldflags
          end

          def has_wxwidgets_xml?
            File.directory?(@wx_xml_path)
          end

          def build_paths
            [ rake_deps_path, src_path, src_gen_path, obj_path, classes_path, common_path, interface_path ]
          end

          def do_bootstrap
            install_prerequisites
            # do we have a local wxWidgets tree already?
            unless File.directory?(File.join(ext_path, 'wxWidgets', 'docs', 'doxygen'))
              wx_checkout
            end
            # do we need to build wxWidgets?
            if get_config('with-wxwin') && get_cfg_string('wxwin').empty?
              chdir(File.join(ext_path, 'wxWidgets')) do
                wx_build
              end
            end
            # generate the doxygen XML output
            wx_generate_xml
            # now we need to respawn the rake command in place of this process
            respawn_rake
          end

          def cleanup_bootstrap
            rm_rf(File.join(ext_path, 'wxWidgets'), verbose: !WXRuby3.config.run_silent?) if File.directory?(File.join(ext_path, 'wxWidgets'))
            cleanup_prerequisites
          end

          # Testing the relevant wxWidgets setup.h file to see what
          # features are supported.

          # The wxWidgets setup.h file contains a series of definitions like
          # #define wxUSE_FOO 1. The location of the file should be set
          # by the platform-specific rakefile. Parse it into a ruby hash:
          def features
            @features ||= _retrieve_features(wx_setup_h)
          end

          def any_feature_set?(*featureset)
            featureset.any? do |feature|
              if ::Array === feature
                features_set?(*feature)
              else
                !!features[feature.to_s]
              end
            end
          end
          private :any_feature_set?

          def features_set?(*featureset)
            featureset.flatten.all? do |feature|
              if AnyOf === feature
                any_feature_set?(*feature.features)
              else
                !!features[feature.to_s]
              end
            end
          end

          def excluded_module?(module_spec)
            explicit_excluded_modules.include?(module_spec.module_name) || !features_set?(*module_spec.requirements)
          end

          def exclude_module(module_name)
            explicit_excluded_modules << module_name
          end

          private

          def explicit_excluded_modules
            @explicit_excluded_modules ||= []
          end

          def _retrieve_features(wxwidgets_setup_h)
            features = {}

            if is_configured? && wxwidgets_setup_h
              File.read(wxwidgets_setup_h).scan(/^\s*#define\s+(wx\w+|__\w+__)\s+([01])/) do | define |
                feat_val = $2.to_i.zero? ? false : true
                feat_id = $1.sub(/\Awx/i, '').gsub(/\A__|__\Z/, '')
                features[feat_id] = feat_val
              end
              # make sure correct platform defines are included as well which will not be the case always
              # (for example __WXMSW__ and __WXOSX__ are not in setup.h)
              features['WXMSW'] = true if features['GNUWIN32']
              features['WXOSX'] = true if features['DARWIN']
              # prior to wxWidgets 3.3 this feature was not set for wxGTK builds
              features['WXGTK'] = true if features['LINUX'] && !features['WXGTK'] && wx_port == :wxgtk
            end

            features
          end

        end
        klass.new
      end
      private :create

      def instance
        @instance ||= create
      end

      def get_config(key)
        v = if WXRuby3::CONFIG.has_key?(key.to_s)
              WXRuby3::CONFIG[key.to_s]
            else
              RB_DEFAULTS.include?(key.to_s) ? RB_CONFIG[key.to_s] : nil
            end
        v = WXRuby3::CONFIG[v[1,v.size]] while String === v && v.start_with?('$') && WXRuby3::CONFIG.has_key?(v[1,v.size])
        v
      end

      def get_cfg_string(key)
        get_config(key) || ''
      end

      def set_config(key, val)
        WXRuby3::CONFIG[key.to_s] = val
      end

      def is_configured?
        instance.is_configured?
      end

      def is_bootstrapped?
        instance.is_bootstrapped?
      end

    end # class << self

  end # module Config

  def self.build_cfg
    Config.build_cfg
  end

  def self.config
    Config.instance
  end

  def self.is_configured?
    Config.is_configured?
  end

  def self.is_bootstrapped?
    Config.is_bootstrapped?
  end

end # module WXRuby3

Dir.glob(File.join(File.dirname(__FILE__), 'ext', '*.rb')).each do |fn|
  require fn
end
