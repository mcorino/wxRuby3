# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

# wxruby sampler command handler
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
              puts '    The directory indicated by DEST *must* already exist.'
              puts
            elsif arg == 'copy'
              unless File.directory?(dest = argv.shift)
                STDERR.puts "ERROR: Invalid destination folder #{dest}"
                exit(1)
              end
              Dir[File.join(WxRuby::ROOT, 'samples', '*')].each do |fp|
                FileUtils.cp_r(fp, dest, verbose: true)
              end
            end
          end
        end
      end
    end

    if self.setup_done?
      self.register('sampler', Sampler)
    end
  end
end
