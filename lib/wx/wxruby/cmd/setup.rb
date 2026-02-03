# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

# wxruby setup command handler
#--------------------------------------------------------------------

require 'fileutils'
require 'json'

module WxRuby
  module Commands
    class Setup

      DESC = 'Run wxRuby3 post-install setup.'

      def self.description
        "    setup -h|[options]\t\t\t#{DESC}"
      end

      def self.options
        Commands.options['setup'] ||= { verbose: Commands.options[:verbose] }
      end

      def self.parse_args(args)
        opts = OptionParser.new
        opts.banner = "#{DESC}\n\nUsage: wxruby setup -h|--help OR wxruby setup [options]\n\n"
        opts.separator ''
        opts.on('--wxwin=path',
                "the installation root for the wxWidgets libraries and headers if not using the system default",
                "(use '@system' to force using system default only)") do |v|
          Setup.options['wxwin'] = (v.downcase == '@system') ? v : File.expand_path(v)
        end
        opts.on('--wxxml=path',
                "the path to the doxygen generated wxWidgets XML interface specs if not using bootstrap")  {|v| Setup.options['wxxml'] = File.expand_path(v)}
        opts.on('--with-wxwin',
                "build a local copy of wxWidgets for use with wxRuby [false]")  {|v| Setup.options['with-wxwin'] = true}
        opts.on('--with-wxhead',
                "build with the head (master) version of wxWidgets [false]", "(implies '--with-wxwin')")  {|v| Setup.options['with-wxhead'] = true}
        opts.on('--wxversion=version',
                'specify wxWidgets release version (xx.xx.xx) to build with (only valid with --with-wxwin)') do |v|
          raise "Invalid version #{v} specified. Version should be '<major>.<minor>.<release>'." unless v =~ /^\d+\.\d+\.\d+$/
          Setup.options['wxversion'] = v
        end
        opts.on('--swig=path',
                "the path to swig executable [swig]")  {|v| Setup.options['swig'] = v}
        opts.on('--doxygen=path',
                "the path to doxygen executable [doxygen]")  {|v| Setup.options['doxygen'] = v}
        opts.on('--git=path',
                "the path to git executable [git]")  {|v| Setup.options['git'] = v}
        opts.on('--[no-]autoinstall',
                "do (not) attempt to automatically install any required packages")  {|v| Setup.options['autoinstall'] = !!v }
        opts.on('--log=PATH',
                "write log to PATH/setup.log (PATH must exist) and do not remove when finished")  {|v| Setup.options['log'] = v }
        opts.on('-h', '--help',
                'Show this message.') do |v|
          puts opts
          puts
          exit(0)
        end
        opts.parse!(args) rescue ($stderr.puts $!.message; exit(127))
      end

      class << self

        private

        def check_wx_config
          !(`which #{@wx_config} 2>/dev/null`).chomp.empty?
        end

      end

      def self.run(argv)
        return description if argv == :describe

        parse_args(argv)

        cfg_args = []
        cfg_args << "--wxwin=#{Setup.options['wxwin']}" if Setup.options['wxwin']
        cfg_args << "--wxxml=#{Setup.options['wxxml']}" if Setup.options['wxxml']
        cfg_args << '--with-wxwin' if Setup.options['with-wxwin']
        cfg_args << '--with-wxhead' if Setup.options['with-wxhead']
        cfg_args << "--wxversion=#{Setup.options['wxversion']}" if Setup.options['wxversion']
        cfg_args << "--swig=#{Setup.options['swig']}" if Setup.options['swig']
        cfg_args << "--doxygen=#{Setup.options['doxygen']}" if Setup.options['doxygen']
        cfg_args << "--git=#{Setup.options['git']}" if Setup.options['git']
        unless Setup.options['autoinstall'].nil?
          cfg_args << (Setup.options['autoinstall'] ? '--autoinstall' : '--no-autoinstall')
        end
        cfg_cmd = 'rake configure'
        cfg_cmd << "[#{cfg_args.join(',')}]" unless cfg_args.empty?

        log_file = File.join(WxRuby::ROOT, 'setup.log')
        if Setup.options['log']
          if File.directory?(Setup.options['log']) && File.writable?(Setup.options['log'])
            log_file = File.join(Setup.options['log'], 'setup.log')
          else
            $stderr.puts "ERROR: cannot write log to #{Setup.options['log']}. Log path must exist and be writable."
            exit(1)
          end
        end
        run_env = {'WXRUBY_RUN_SILENT' => "#{log_file}"}
        run_env['WXRUBY_VERBOSE'] = '1' if Setup.options[:verbose]

        result = false

        FileUtils.chdir(WxRuby::ROOT) do
          # first run the configure command
          result = system(run_env, "#{cfg_cmd}")

          # if succeeded
          if result
            # load the wxRuby3 build config
            build_cfg = ::JSON.load(File.read('.wxconfig'))

            # now determine the steps to execute
            steps = 0
            actions_txt = if Setup.options['autoinstall'] != false
                            steps = 1
                            '(possibly) install required software'
                          else
                            ''
                          end
            if build_cfg['with-wxwin'] || (!build_cfg['wxwin'].to_s.empty? && build_cfg['wxwin'].to_s != '@system')
              actions_txt << ', ' if steps>0
              actions_txt << 'build the wxWidgets libraries, '
              actions_txt << "\n" if steps>0
              steps += 1
            else
              actions_txt << ',' if steps>0
            end
            actions_txt << 'build the native wxRuby3 extensions '
            actions_txt << "\n" if steps==1
            actions_txt << 'and generate the wxRuby3 reference documentation.'
            $stdout.puts <<~__INFO_TXT
  
              ---            
              Now running wxRuby3 post-install setup.
              This will #{actions_txt}
              Please be patient as this may take quite a while depending on your system.
              (#{steps >= 2 ? '10-15' : '5-10'} min on a modern PC with multicore CPU but longer with older/slower CPUs)
              ---
  
              __INFO_TXT
            # can't rely on FileUtils#chdir returning the block result (bug in older Rubies) so assign result here
            result = system(run_env, "rake -m wxruby:gem:setup#{Setup.options['log'] ? '[:keep_log]' : ''} && gem rdoc wxruby3 --overwrite")
          end
        end
        exit(result ? 0 : 1)
      end
    end

    unless self.setup_done?
      self.register('setup', Setup)
    end
  end
end
