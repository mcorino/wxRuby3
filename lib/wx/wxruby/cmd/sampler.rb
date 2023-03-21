# wxruby sampler command handler
# Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

require 'fileutils'

module WxRuby
  module Commands
    class Sampler
      OPTIONS = {
        save_path: nil
      }

      def self.description
        "    sampler [help]|[copy DEST]\tRun wxRuby3 Sampler application (or copy samples)."
      end

      def self.parse_args(args)
        opts = OptionParser.new
        opts.banner = "Usage: wxruby [global options] sampler [-h]|[-s PATH]\n"
        opts.separator ''
        opts.on('-s PATH', '--save=PATH',
                'Save wxRuby samples under PATH.') do |v|
          OPTIONS[:save_path] = v.to_s
        end
        opts.on('-h', '--help',
                'Show this message.') do |v|
          puts opts
          puts
          exit(0)
        end
        opts.raise_unknown = false
        opts.parse!(args)
      end

      def self.run(argv)
        if argv == :describe
          description
        else
          if argv.empty?
            exec(RUBY, File.join(WxRuby::ROOT, 'samples', 'sampler.rb'))
          else
            arg = argv.shift
            if arg == 'help'
              puts 'Usage: wxruby [global options] sampler [help]|[copy DEST]'
              puts
              puts '    Starts the sampler application if called without arguments.'
              puts '    Otherwise shows this help for argument "help" or copies the included wxRuby'
              puts '    sample folders under the directory indicated by DEST for argument "copy DEST".'
              puts '    The directory indicated  by DEST *must* already exist.'
              puts
            elsif arg == 'copy'
              unless File.directory?(dest = argv.shift)
                STDERR.puts "ERROR: Invalid destination folder #{DEST}"
                exit(1)
              end
              Dir[File.join(WxRuby::ROOT, 'samples', '*')].each do |fp|
                FileUtils.cp_r(fp, dest, verbose: true, noop: true)
              end
            end
          end
        end
      end
    end

    self.register('sampler', Sampler)
  end
end
