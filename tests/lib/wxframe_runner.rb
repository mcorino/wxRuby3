
require_relative './wxapp_runner'

module WxRuby

  module Test

    class App < Wx::App
      def on_init
        @tests_have_run = false
        evt_idle :on_idle
        @frame = Wx::Frame.new(nil, size: [600,400])
        @frame.show
      end

      def on_idle(_evt)
        done = @tests_have_run
        @tests_have_run = true
        @result = @start_mtd.bind(@test_runner).call unless done
      end

      attr_reader :frame
    end

    class GUITests < ::Test::Unit::TestCase

      class << self

        def shutdown
          Wx.get_app.frame.hide
          Wx.get_app.frame.destroy
          super
        end

        attr_reader :frame

      end

      def test_frame
        Wx.get_app.frame
      end

      def count_events(win, evt, id1=Wx::ID_ANY, id2=nil)
        return 0 unless block_given?
        evt_count = 0
        if id2.nil?
          win.event_handler.send(evt.to_sym, id1, ->(_evt){ evt_count += 1 })
        else
          win.event_handler.send(evt.to_sym, id1, id2, ->(_evt){ evt_count += 1 })
        end
        yield
        evt_count
      end

    end

  end

end
