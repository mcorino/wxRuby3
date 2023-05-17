
require 'test/unit'
require 'test/unit/ui/console/testrunner'
require 'wx'

module Wx::SF

  module Test

    class App < Wx::App
      def initialize(test_runner, start_mtd)
        super()
        @test_runner = test_runner
        @start_mtd = start_mtd
      end

      def on_init
        @result = @start_mtd.bind(@test_runner).call
        false
      end

      attr_reader :result
    end

    if defined? ::IntelliJ
      require 'test/unit/ui/teamcity/testrunner'
      BaseRunner = ::Test::Unit::UI::TeamCity::TestRunner
    else
      BaseRunner = ::Test::Unit::UI::Console::TestRunner
    end

    class Runner < BaseRunner

      org_start_mtd = instance_method :start
      define_method :start do
        (app = Wx::SF::Test::App.new(self, org_start_mtd)).run
        app.result
      end

    end

  end

end

module Test
  module Unit
    AutoRunner.register_runner(:wxapp) do |auto_runner|
      Wx::SF::Test::Runner
    end
    AutoRunner.default_runner = :wxapp
    if defined? ::IntelliJ
      class AutoRunner
        alias :wx_initialize :initialize
        private :wx_initialize

        def initialize(*args)
          wx_initialize(*args)
          @runner = AutoRunner.default_runner
        end
      end
    end
  end
end
