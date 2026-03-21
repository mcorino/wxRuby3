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

    class Unit < Minitest::Test

      def self.is_macos?
        Wx::PLATFORM == 'WXOSX'
      end

      def is_macos?
        Unit.is_macos?
      end

      def self.is_msw?
        Wx::PLATFORM == 'WXMSW'
      end

      def is_msw?
        Unit.is_msw?
      end

      def self.is_gtk?
        Wx::PLATFORM == 'WXGTK'
      end

      def is_gtk?
        Unit.is_gtk?
      end

      def self.is_qt?
        Wx::PLATFORM == 'WXQT'
      end

      def is_qt?
        Unit.is_qt?
      end

      def self.is_ci_build?
        (ENV['GITHUB_ACTION'] || ENV['CI'])
      end

      def is_ci_build?
        Unit.is_ci_build?
      end

      def self.is_cirrus_ci_build?
        (ENV['CIRRUS_CI'] || ENV['CI'])
      end

      def is_cirrus_ci_build?
        Unit.is_cirrus_ci_build?
      end

      def self.uses_wayland?
        Wx.has_feature?('HAVE_WAYLAND_CLIENT')
      end

      def uses_wayland?
        Unit.uses_wayland?
      end

    end

  end

end

module Minitest

  RUN_ALL_METHOD = VERSION >= '6.0.0' ? :run_all_suites : :__run

  class << self
    org_run_all_suites_mtd = instance_method RUN_ALL_METHOD
    define_method RUN_ALL_METHOD do |*args, **kwargs|
      (app = WxRuby::Test::App.new(self, org_run_all_suites_mtd, *args, **kwargs)).run
      app.result
    end
  end

end
