
require_relative './wxapp_runner'

module WxRuby

  module Test

    class App < Wx::App

      Assert = Struct.new(:file, :line, :func, :condition, :message)

      class AssertFailureSink
        def initialize
          @asserts = []
        end

        attr_reader :asserts

        def asserts?
          !@asserts.empty?
        end

        def <<(assert)
          @asserts << assert
        end
      end

      def on_init
        @assert_sink = nil
        @tests_have_run = false
        evt_idle :on_idle
        @frame = Wx::Frame.new(nil, size: [600,400])
        @frame.show
      end

      def on_idle(_evt)
        done = @tests_have_run
        @tests_have_run = true
        @result = @start_mtd.bind(@test_runner).call unless done
        self.exit_main_loop
      end

      attr_reader :frame

      def open_assert_sink
        @assert_sink = AssertFailureSink.new
      end

      def close_assert_sink
        @assert_sink = nil
      end

      def asserts
        @assert_sink.asserts
      end

      def asserts?
        @assert_sink.asserts?
      end

      def on_assert_failure(file, line, func, condition, message)
        if @assert_sink
          @assert_sink << Assert.new(file, line, func, condition, message)
        else
          super
        end
      end
    end

    class GUITests < ::Test::Unit::TestCase

      def test_frame
        Wx.get_app.frame
      end

      class EventCounter
        def initialize
          @count = 0
        end
        attr_accessor :count

        def inc
          @count +=1
        end
      end

      def self.has_ui_simulator?
        Wx.has_feature?(:USE_UIACTIONSIMULATOR) && (Wx::PLATFORM != 'WXOSX' || Wx::WXWIDGETS_VERSION >= '3.3')
      end

      def count_events(win, evt, id1=Wx::ID_ANY, id2=nil)
        return 0 unless block_given?
        evt_count = EventCounter.new
        if Wx::EvtHandler.event_type_arity(evt) == 0
          win.event_handler.send(evt.to_sym, ->(evt){ evt_count.inc; evt.skip if !evt.command_event? })
        elsif id2.nil?
          win.event_handler.send(evt.to_sym, id1, ->(evt){ evt_count.inc; evt.skip if !evt.command_event? })
        else
          win.event_handler.send(evt.to_sym, id1, id2, ->(evt){ evt_count.inc; evt.skip if !evt.command_event? })
        end
        begin
          yield evt_count
        ensure
          win.event_handler.disconnect(id1, id2 || Wx::ID_ANY, evt.to_sym)
        end
        evt_count.count
      end

      def assert_with_assertion_failure(max_asserts: nil, func: nil, &block)
        Wx.get_app.open_assert_sink
        begin
          block.call
          raise StandardError.new('No Wx assertion failure captured!') unless Wx.get_app.asserts?
          raise StandardError.new("Too many assertion failures captures! Expected max #{max_asserts}, captured #{Wx.get_app.asserts.size}") if max_asserts && max_asserts < Wx.get_app.asserts.size
          raise StandardError.new("Unexpected assertions failures. Expected assertion failure from #{func} but captured assertions from #{Wx.get_app.asserts.collect {|a| a.func } }") if func && !Wx.get_app.asserts.any? { |a| a.func == func }
        ensure
          Wx.get_app.close_assert_sink
        end
      end

    end

  end

end
