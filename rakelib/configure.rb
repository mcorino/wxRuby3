# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 rake file
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
                "the installation root for the wxWidgets libraries and headers if not using the system default",
                "(use '@system' to force using system default only)")  { |v|
          if v.downcase == '@system'
            CONFIG[WXW_SYS_KEY] = true
            CONFIG['wxwin'] = nil
            CONFIG['with-wxwin'] = false
          else
            CONFIG['wxwin'] = File.expand_path(v)
            CONFIG[WXW_SYS_KEY] = false
          end
        }
        opts.on('--wxxml=path',
                "the path to the doxygen generated wxWidgets XML interface specs if not using bootstrap")  {|v| CONFIG['wxxml'] = File.expand_path(v)}
        opts.on('--wxwininstdir=path',
                "the directory where the wxWidgets dlls are installed (do not change if not absolutely needed) [#{instance.get_config('wxwininstdir')}]") {|v| CONFIG['wxwininstdir'] = v}
        opts.on('--with-wxwin',
                "build a local copy of wxWidgets for use with wxRuby [false]")  { |v|
          CONFIG['with-wxwin'] = true
          CONFIG[WXW_SYS_KEY] = false
        }
        opts.on('--with-debug',
                "build with debugger support [#{instance.get_config('with-debug')}]")  {|v| CONFIG['with-debug'] = true}
        opts.on('--swig=path',
                "the path to swig executable [#{get_config('swig')}]")  {|v| CONFIG['swig'] = v}
        opts.on('--doxygen=path',
                "the path to doxygen executable [#{get_config('doxygen')}]")  {|v| CONFIG['doxygen'] = v}
        opts.on('--git=path',
                "the path to git executable [#{get_config('git')}]")  {|v| CONFIG['git'] = v}
        opts.on('--[no-]autoinstall',
                "do (not) attempt to automatically install any required packages")  {|v| CONFIG['autoinstall'] = !!v }

        opts.separator ""

        opts.on('--help', 'Show this help message') { puts opts; puts; exit }
      end.parse!(args.extras.dup)
    end

    def self.check
      instance.init # re-initialize

      # should we try to use a system or user defined wxWidgets installation?
      if !get_config('with-wxwin')

        # check if a user defined wxWidgets location is specified or should be using a system standard install
        if get_cfg_string('wxwin').empty?
          # assume/force system standard install; will be checked below
          set_config('wxwininstdir', get_cfg_string('libdir')) if get_cfg_string('wxwininstdir').empty?
        elsif get_cfg_string('wxwininstdir').empty? # if not explicitly specified derive from 'wxwin'
          if instance.windows?
            set_config('wxwininstdir', File.join(get_cfg_string('wxwin'), 'bin'))
          else
            set_config('wxwininstdir', File.join(get_cfg_string('wxwin'), 'lib'))
          end
        end

      # or should we use an embedded (automatically built) wxWidgets installation
      else

        set_config('wxwininstdir', instance.ext_dir)

      end

      if !get_cfg_string('wxwin').empty? || !get_config('with-wxwin')
        # check wxWidgets availability through 'wx-config' command
        if instance.check_wx_config
          if instance.wx_config("--version") < '3.2.0'
            if get_cfg_string('wxwin').empty? && get_cfg_string('wxxml').empty? && !get_config(WXW_SYS_KEY)
              # no custom (or forced system) wxWidgets build specified so switch to assuming we should include building wxWidgets ourselves
              set_config('with-wxwin', true)
            else
              # if someone wants to customize they HAVE to do it right
              STDERR.puts "ERROR: Incompatible wxWidgets version. wxRuby requires a wxWidgets >= 3.2.0 release."
              exit(1)
            end
          end
        else
          if get_cfg_string('wxwin').empty? && get_cfg_string('wxxml').empty? && !get_config(WXW_SYS_KEY)
            # no custom (or forced system) wxWidgets build specified so switch to assuming we should include building wxWidgets ourselves
            set_config('with-wxwin', true)
          else
            # if someone wants to customize they HAVE to do it right
            STDERR.puts "ERROR: Cannot find wxWidgets. wxRuby requires a wxWidgets >= 3.2.0 release."
            exit(1)
          end
        end
      # else we're assumed to build wxWidgets ourselves so cannot test anything yet
      end

      if get_cfg_string('wxxml').empty? && !get_cfg_string('wxwin').empty?
        # in case of a custom wxWidgets build and no explicit xml path check if the custom build holds this
        xml_path = File.join(get_cfg_string('wxwin'), 'docs', 'doxygen', 'out', 'xml')
        # if not there see if the standard setup 'wxw_root/<install dir>' was used
        xml_path = File.join(get_cfg_string('wxwin'), '..', 'docs', 'doxygen', 'out', 'xml') unless File.directory?(xml_path)
        if File.directory?(xml_path) && !Dir.glob(File.join(xml_path, '*.xml')).empty?
          set_config('wxxml', xml_path)
        end
      end

    end

  end

end
