###
# wxRuby3 rake file
# Copyright (c) M.J.N. Corino, The Netherlands
###

require 'yaml'
require_relative './lib/config'

CLOBBER.include WXRuby3.build_cfg

module WXRuby3

  module Config

    def self.define(task, args)
      OptionParser.new do |opts|
        opts.banner = <<~__USAGE
          Usage: rake RAKE_OPTIONS -- #{task.name}[TASK_OPTIONS]

          TASK_OPTIONS need to be specified as '<taskname>[<opt>,<opt>,...]' without whitespaces.
          In case whitespaces are needed enclose the entire string in "" like "<taskname>[<opt>,<opt>,...]".
          __USAGE

        opts.separator ""

        opts.on('--prefix=path',
                "path prefix of target environment [#{get_config('prefix')}]") {|v| set_config('prefix', File.expand_path(v))}
        opts.on('--bindir=path',
                "the directory for commands [#{RB_CONFIG['bindir']}]") {|v| CONFIG['bindir'] = v}
        opts.on('--libdir=path',
                "the directory for libraries [#{RB_CONFIG['libdir']}]")  {|v| CONFIG['libdir'] = v}
        opts.on('--datadir=path',
                "the directory for shared data [#{RB_CONFIG['datadir']}]")  {|v| CONFIG['datadir'] = v}
        opts.on('--mandir=path',
                "the directory for man pages [#{RB_CONFIG['mandir']}]")  {|v| CONFIG['mandir'] = v}
        opts.on('--sysconfdir=path',
                "the directory for system configuration files [#{RB_CONFIG['sysconfdir']}]")  {|v| CONFIG['sysconfdir'] = v}
        opts.on('--localstatedir=path',
                "the directory for local state data [#{RB_CONFIG['localstatedir']}]")  {|v| CONFIG['localstatedir'] = v}
        opts.on('--libruby=path',
                "the directory for ruby libraries [#{get_config('libruby')}]")  {|v| CONFIG['libruby'] = v}
        opts.on('--librubyver=path',
                "the directory for standard ruby libraries [#{get_config('librubyver')}]")  {|v| CONFIG['librubyver'] = v}
        opts.on('--librubyverarch=path',
                "the directory for standard ruby extensions [#{get_config('librubyverarch')}]")  {|v| CONFIG['librubyverarch'] = v}
        opts.on('--siteruby=path',
                "the directory for version-independent aux ruby libraries [#{get_config('siteruby')}]")  {|v| CONFIG['siteruby'] = v}
        opts.on('--siterubyver=path',
                "the directory for aux ruby libraries [#{get_config('siterubyver')}]")  {|v| CONFIG['siterubyver'] = v}
        opts.on('--siterubyverarch=path',
                "the directory for aux ruby binaries [#{get_config('siterubyverarch')}]")  {|v| CONFIG['siterubyverarch'] = v}
        opts.on('--rbdir=path',
                "the directory for ruby scripts [#{get_config('rbdir')}]")  {|v| CONFIG['rbdir'] = v}
        opts.on('--sodir=path',
                "the directory for ruby extensions [#{get_config('sodir')}]")  {|v| CONFIG['sodir'] = v}
        opts.on('--wxwin=path',
                "the installation root for the wxWidgets libraries and headers if not using the system default")  {|v| CONFIG['wxwin'] = File.expand_path(v)}
        opts.on('--wxxml=path',
                "the path to the doxygen generated wxWidgets XML interface specs if not using bootstrap")  {|v| CONFIG['wxxml'] = File.expand_path(v)}
        opts.on('--wxwininstdir=path',
                "the directory where the wxWidgets dlls are to be installed for wxRuby [#{instance.get_config('wxwininstdir')}]") {|v| CONFIG['wxwininstdir'] = v}
        opts.on('--with-wxwin',
                "build a local copy of wxWidgets for use with wxRuby [false]")  {|v| CONFIG['with-wxwin'] = true}
        opts.on('--with-debug',
                "build with debugger support [#{instance.get_config('with-debug')}]")  {|v| CONFIG['with-debug'] = true}
        opts.on('--swig=path',
                "the path to swig executable [#{get_config('swig')}]")  {|v| CONFIG['swig'] = v}
        opts.on('--doxygen=path',
                "the path to doxygen executable [#{get_config('doxygen')}]")  {|v| CONFIG['doxygen'] = v}

        opts.separator ""

        opts.on('--help', 'Show this help message') { puts opts; puts; exit }
      end.parse!(args.extras.dup)
    end

    def self.check
      instance.init # re-initialize

      if Dir[File.join('ext', 'wxruby_*.so')].empty? # Don't check for wxWidgets installation when executed for binary gem install

        if !get_config('with-wxwin')
          # check if a user defined wxWidgets location is specified or we're using a system standard install
          if get_cfg_string('wxwin').empty?
            # assume system standard install; will be checked below
            set_config('wxwininstdir', get_cfg_string('libdir')) if get_cfg_string('wxwininstdir').empty?
          elsif get_cfg_string('wxwininstdir').empty?
            if instance.windows?
              set_config('wxwininstdir', File.join(get_cfg_string('wxwin'), 'bin'))
            else
              set_config('wxwininstdir', File.join(get_cfg_string('wxwin'), 'lib'))
            end
          end
        elsif !get_cfg_string('wxwin').empty?
          if get_cfg_string('wxwininstdir').empty?
            if instance.windows?
              set_config('wxwininstdir', File.join(get_cfg_string('wxwin'), 'bin'))
            else
              set_config('wxwininstdir', File.join(get_cfg_string('wxwin'), 'lib'))
            end
          end
        else
          set_config('wxwininstdir', get_cfg_string('sodir')) if get_cfg_string('wxwininstdir').empty?
        end

        if !get_cfg_string('wxwin').empty? || !get_config('with-wxwin')
          # check wxWidgets availability through 'wx-config' command
          if instance.check_wx_config
            if instance.wx_config("--version") < '3.2.0'
              STDERR.puts "ERROR: Incompatible wxWidgets version. wxRuby requires a wxWidgets >= 3.2.0 release."
              exit(1)
            end
          else
            STDERR.puts "ERROR: Cannot find wxWidgets. wxRuby requires a wxWidgets >= 3.2.0 release."
            exit(1)
          end
        # else we're are assumed to build wxWidgets ourselves so cannot test anything yet
        end

        if get_cfg_string('wxxml').empty?
          # no pre-generated XML specified so we are going to need Git and Doxygen
          instance.check_git
          instance.check_doxygen
        end

      end
    end

  end

end
