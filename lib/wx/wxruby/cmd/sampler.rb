# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

# wxruby sampler command handler
#--------------------------------------------------------------------

require 'fileutils'

module WxRuby
  module Commands
    class Sampler

      DESC = 'Run wxRuby3 Sampler application (or copy samples).'

      def self.description
        "    sampler -h|[options]\t\t#{DESC}"
      end

      def self.options
        Commands.options['sampler'] ||= { verbose: Commands.options[:verbose] }
      end

      def self.parse_args(args)
        opts = OptionParser.new
        opts.banner = "#{DESC}\n\nUsage: wxruby sampler -h|--help OR wxruby sampler [options]\n\n" +
          "Runs the sampler application if no options specified.\n\n"
        opts.separator ''
        opts.on('--copy=DEST',
                'Copies the included wxRuby sample folders under the directory indicated by DEST (MUST exist)')  {|v| Sampler.options[:copy] << v }
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

        if options[:copy]
          unless File.directory?(dest = options[:copy])
            $stderr.puts "ERROR: Invalid destination folder #{dest}"
            exit(1)
          end
          Dir[File.join(WxRuby::ROOT, 'samples', '*')].each do |fp|
            FileUtils.cp_r(fp, dest, verbose: true)
          end
        else
          exec(RUBY, File.join(WxRuby::ROOT, 'samples', 'sampler.rb'))
        end
      end
    end

    if self.setup_done?
      self.register('sampler', Sampler)
    end
  end
end
