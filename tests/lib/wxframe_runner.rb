
require_relative './wxapp_runner'

module WxRuby

  module Test

    class GUITests < ::Test::Unit::TestCase

      class << self

        def startup
          super
          @frame = Wx::Frame.new(nil, size: [600,400])
          @frame.show
          Wx.get_app.yield
        end

        def shutdown
          @frame.hide
          @frame.destroy
          Wx.get_app.yield
          super
        end

        attr_reader :frame

      end

      def test_frame
        GUITests.frame
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
