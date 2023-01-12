require 'test/unit'
require 'test/unit/ui/console/testrunner'
require 'wx'

class EventTests < Test::Unit::TestCase

  def test_event
    evt = Wx::Event.new(100, 1)
    assert_equal(100, evt.event_type)
    assert_equal(1, evt.id)
    assert_boolean(!evt.should_propagate)
    evt.skip
    assert_boolean(evt.skipped)
    evt_dup = evt.clone
    assert_not_equal(evt, evt_dup)
    assert_equal(evt.event_type, evt_dup.event_type)
    assert_equal(evt.id, evt_dup.id)
  end

  def test_command_event
    evt = Wx::CommandEvent.new(100, 1)
    assert_equal(100, evt.event_type)
    assert_equal(1, evt.id)
    assert_boolean(evt.should_propagate)
    evt.skip
    assert_boolean(evt.skipped)
    evt.string = 'CommandEvent Test'
    assert_equal('CommandEvent Test', evt.string)
    evt_dup = evt.clone
    assert_not_equal(evt, evt_dup)
    assert_equal(evt.event_type, evt_dup.event_type)
    assert_equal(evt.id, evt_dup.id)
    assert_equal(evt.string, evt_dup.string)
  end
end

class TestApp < Wx::App
  def on_init
    Test::Unit::UI::Console::TestRunner.run(EventTests)
    false
  end
end

app = TestApp.new
app.run
