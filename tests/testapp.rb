require 'test/unit'
require 'wx'

class TestingFrame < Wx::Frame
    def initialize
        super(nil, -1, '')
        evt_paint {on_paint}
    end

    def on_paint
        paint {}
        close
    end
end

class AppWithSimpleFrame < Wx::App
    attr_reader(:did_call_on_exit)

    def on_init
        TestingFrame.new.show
    end

    def on_exit
        @did_call_on_exit = true
        return 0
    end
end

class TestApp < Test::Unit::TestCase
  def test_self_closing_frame
    o = AppWithSimpleFrame.new
    o.run
    assert(o.did_call_on_exit, "didn't call on_exit?")
  end
end

if $0 == __FILE__
  require 'test/unit/ui/console/testrunner'
  Test::Unit::UI::Console::TestRunner.run(TestApp)
end
