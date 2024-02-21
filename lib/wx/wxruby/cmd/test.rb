# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

# wxruby unit test command handler
#--------------------------------------------------------------------

require 'fileutils'

module WxRuby
  module Commands
    class Test

      DESC = 'Run wxRuby3 regression tests.'

      def self.description
        "    test -h|[options] [TEST [...]]\t#{DESC}"
      end

      def self.options
        Commands.options['test'] ||= { verbose: Commands.options[:verbose], excludes: [] }
      end

      def self.parse_args(args)
        opts = OptionParser.new
        opts.banner = "#{DESC}\n\nUsage: wxruby test -h|--help OR wxruby test [options] [TEST [...]]\n\n" +
          "TEST == test name\n" +
          "Runs all tests (except any specified to exclude) if no test specified.\n\n"
        opts.separator ''
        opts.on('--list',
                "display the list of names of the installed tests")  do |v|
          tests = Dir[File.join(WxRuby::ROOT, 'tests', '*.rb')].collect { |t| File.basename(t, '.*') }
          $stdout.puts <<~__INFO
            Installed wxRuby tests:
              #{tests.join(', ')}

            __INFO
          exit(0)
        end
        opts.on('--exclude=TEST',
                "exclude the specified test from running")  {|v| Test.options[:excludes] << v }
        opts.on('-h', '--help',
                'Show this message.') do |v|
          puts opts
          puts
          exit(0)
        end
        opts.parse!(args) rescue ($stderr.puts $!.message; exit(127))
      end

      def self.run(argv)
        return description if argv == :describe

        parse_args(argv)

        tests = if argv.empty?
                  Dir[File.join(WxRuby::ROOT, 'tests', '*.rb')]
                else
                  argv.collect do |a|
                    fn = File.join(WxRuby::ROOT, 'tests', a+'.rb')
                    unless File.file?(fn)
                      $stderr.puts "ERROR: Invalid test [#{a}] specified."
                      exit(1)
                    end
                    fn
                  end
                end
        tests.each do |test|
          unless Test.options[:excludes].include?(File.basename(test, '.*'))
            exit(1) unless system(RUBY, test)
          end
        end
      end
    end

    if self.setup_done?
      self.register('test', Test)
    end
  end
end
