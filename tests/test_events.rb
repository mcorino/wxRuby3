# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

require_relative './lib/wxapp_runner'

class EventTests < Test::Unit::TestCase

  def test_event
    evt = Wx::Event.new(100, 1)
    assert_equal(100, evt.event_type)
    assert_equal(1, evt.id)
    assert(!evt.should_propagate)
    evt.skip
    assert(evt.skipped)
    evt_dup = evt.clone
    assert_not_equal(evt, evt_dup)
    assert_equal(evt.event_type, evt_dup.event_type)
    assert_equal(evt.id, evt_dup.id)
  end

  def test_command_event
    GC.start
    evt = Wx::CommandEvent.new(100, 1)
    evt.set_client_object({one: 'first'})
    assert_equal(100, evt.event_type)
    assert_equal(1, evt.id)
    assert_equal({one: 'first'}, evt.get_client_object)
    assert(evt.should_propagate)
    GC.start
    evt.skip
    assert(evt.skipped)
    evt.string = 'CommandEvent Test'
    assert_equal('CommandEvent Test', evt.string)
    evt_dup = evt.clone
    GC.start
    assert_not_equal(evt, evt_dup)
    assert_equal(evt.event_type, evt_dup.event_type)
    assert_equal(evt.id, evt_dup.id)
    assert_equal(evt.string, evt_dup.string)
    assert_equal({one: 'first'}, evt.get_client_object)
    assert_equal({one: 'first'}, evt_dup.get_client_object)
  end

  def test_event_clone
    evt = Wx::MouseEvent.new(Wx::EVT_LEFT_DOWN)
    assert_equal(Wx::EVT_LEFT_DOWN, evt.event_type)
    evt.position = Wx::Point.new(333,666)
    assert_equal(Wx::Point.new(333,666), evt.position)
    evt_dup = evt.clone
    assert_instance_of(Wx::MouseEvent, evt_dup)
    assert_not_equal(evt, evt_dup)
    assert_equal(evt.event_type, evt_dup.event_type)
    assert_equal(evt.position, evt_dup.position)
  end
end
