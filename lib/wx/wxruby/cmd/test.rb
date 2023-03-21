# wxruby unit test command handler
# Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

require 'fileutils'

module WxRuby
  module Commands
    class Test
      def self.description
        "    test\t\t\tRun wxRuby3 regression tests."
      end

      def self.run(argv)
        if argv == :describe
          description
        else
          Dir[File.join(WxRuby::ROOT, 'tests', '*.rb')].each do |test|
            system(RUBY, test)
          end
        end
      end
    end

    self.register('test', Test)
  end
end
