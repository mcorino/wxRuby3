# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

require_relative './wxrb_test'
require 'wx'

module WxRuby

  module Test

    class App < Wx::App
      def initialize(test_runner, start_mtd, *args, **kwargs)
        super()
        @test_runner = test_runner
        @start_mtd = start_mtd
        @args = args
        @kwargs = kwargs
      end

      protected def run_all_tests
        @start_mtd.bind(@test_runner).call(*@args, **@kwargs)
      end

      def on_init
        @result = run_all_tests
        false
      end

      attr_reader :result
    end

  end

end

module Test
  module Unit
    class TestCase < Minitest::Test

      def self.is_ci_build?
        (ENV['GITHUB_ACTION'] || ENV['CI'])
      end

      def is_ci_build?
        TestCase.is_ci_build?
      end

      def self.uses_wayland?
        Wx.has_feature?('HAVE_WAYLAND_CLIENT')
      end

      def uses_wayland?
        TestCase.uses_wayland?
      end

    end
  end
end

module Minitest

  class << self
    org_run_all_suites_mtd = instance_method :run_all_suites
    define_method :run_all_suites do |*args, **kwargs|
      (app = WxRuby::Test::App.new(self, org_run_all_suites_mtd, *args, **kwargs)).run
      app.result
    end
  end

end
