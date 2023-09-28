# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

require 'test/unit'
require 'test/unit/ui/console/testrunner'
require 'wx'

module WxRuby

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
        (app = WxRuby::Test::App.new(self, org_start_mtd)).run
        app.result
      end

    end

  end

end

module Test
  module Unit
    AutoRunner.register_runner(:wxapp) do |auto_runner|
      WxRuby::Test::Runner
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

    class TestCase

      def self.is_ci_build?
        !!ENV['GITHUB_ACTION']
      end

      def is_ci_build?
        TestCase.is_ci_build?
      end

    end
  end
end
