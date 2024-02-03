# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

# wxruby setup command handler
#--------------------------------------------------------------------

require 'fileutils'

module WxRuby
  module Commands
    class Setup

      DESC = 'Run wxRuby3 post-install setup.'

      def self.description
        "    setup -h|[options]\t\t#{DESC}"
      end

      def self.options
        Commands.options['setup'] ||= { verbose: Commands.options[:verbose] }
      end

      def self.parse_args(args)
        opts = OptionParser.new
        opts.banner = "#{DESC}\n\nUsage: wxruby setup -h|--help OR wxruby setup [options]\n\n"
        opts.separator ''
        opts.on('--wxwin=path',
                "the installation root for the wxWidgets libraries and headers if not using the system default")  {|v| Setup.options['wxwin'] = File.expand_path(v)}
        opts.on('--wxxml=path',
                "the path to the doxygen generated wxWidgets XML interface specs if not using bootstrap")  {|v| Setup.options['wxxml'] = File.expand_path(v)}
        opts.on('--with-wxwin',
                "build a local copy of wxWidgets for use with wxRuby [false]")  {|v| Setup.options['with-wxwin'] = true}
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
        opts.parse!(args)
      end

      def self.run(argv)
        return description if argv == :describe

        parse_args(argv)

        cfg_args = []
        cfg_args << "--wxwin=#{Setup.options['wxwin']}" if Setup.options['wxwin']
        cfg_args << "--wxxml=#{Setup.options['wxxml']}" if Setup.options['wxxml']
        cfg_args << '--with-wxwin' if Setup.options['with-wxwin']
        cfg_args << "--swig=#{Setup.options['swig']}" if Setup.options['swig']
        cfg_args << "--doxygen=#{Setup.options['doxygen']}" if Setup.options['doxygen']
        cfg_args << "--git=#{Setup.options['git']}" if Setup.options['git']
        unless Setup.options['autoinstall'].nil?
          cfg_args << (Setup.options['autoinstall'] ? '--autoinstall' : '--no-autoinstall')
        end
        cfg_cmd = 'rake configure'
        cfg_cmd << "[#{cfg_args.join(',')}]" unless cfg_args.empty?

        result = false
        FileUtils.chdir(WxRuby::ROOT) do
          steps = 0
          actions_txt = if Setup.options['autoinstall'] != false
                          steps = 1
                          '(possibly) install required software'
                        else
                          ''
                        end
          if Setup.options['with-wxwin'] || Setup.options['wxwin'].nil?
            actions_txt << ', ' if steps>0
            actions_txt << 'build the wxWidgets libraries (if needed), '
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
            ---

            __INFO_TXT
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
          # can't rely on FileUtils#chdir returning the block result (bug in older Rubies) so assign result here
          result = system(run_env, "#{cfg_cmd} && rake -m wxruby:gem:setup#{Setup.options['log'] ? '[:keep_log]' : ''} && gem rdoc wxruby3 --overwrite")
        end
        exit(result ? 0 : 1)
      end
    end

    unless self.setup_done?
      self.register('setup', Setup)
    end
  end
end
