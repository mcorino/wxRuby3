# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 memcheck buildtools extensions
###

begin
require 'ruby_memcheck'
module WXRuby3

  module Config

    include RubyMemcheck::TestTaskReporter unless RubyMemcheck::TestTaskReporter.is_a?(::Class)

    def configuration
      @configuration
    end

    def memcheck(*args, **options)
      RubyMemcheck.config(binary_name: "wxruby_core",
                          valgrind_suppressions_dir: File.join(Config.wxruby_root, 'rakelib', 'memcheck', 'suppressions'),
                          valgrind_generate_suppressions: !!options[:gensup])
      options.delete(:gensup)
      args.unshift("-r#{File.join('ruby_memcheck', 'test_helper.rb')}")
      args.unshift("-I#{File.join(Config.wxruby_root, 'lib')}")
      @configuration = RubyMemcheck.default_configuration
      command = configuration.command(args)

      if RubyMemcheck::TestTaskReporter.is_a?(::Class)
        @reporter = RubyMemcheck::TestTaskReporter.new(configuration)

        @reporter.setup
      end

      Rake.sh(Config.instance.exec_env, command, **options) do |ok, res|
        if RubyMemcheck::TestTaskReporter.is_a?(::Class)
          @reporter.report_valgrind_errors
        else
          report_valgrind_errors
        end

        yield ok, res if block_given?
      end
    end

  end

end
rescue LoadError
end
