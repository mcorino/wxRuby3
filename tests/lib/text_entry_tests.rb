
module TextEntryTests

  def test_te_set_value
    text_entry.set_focus # removes the 'Hint' test which in GTK2 causes problems
    assert(text_entry.empty?)

    text_entry.value = 'foo'
    assert_equal('foo', text_entry.value)

    text_entry.value = ''
    assert(text_entry.empty?)

    text_entry.value = 'hi'
    assert_equal('hi', text_entry.value)

    text_entry.value = 'bye'
    assert_equal('bye', text_entry.value)
  end

  def test_te_text_change_events
    updates = count_events(text_entry, :evt_text) do |c_upd|

      # WXQT only sends event when text changes
      unless Wx::PLATFORM == 'WXQT'
        text_entry.value = ''
        assert_equal(1, c_upd.count)
        c_upd.count = 0
      end

      text_entry.value = 'foo'
      assert_equal(1, c_upd.count)
      c_upd.count = 0

      # WXQT only sends event when text changes
      unless Wx::PLATFORM == 'WXQT'
        text_entry.value = 'foo'
        assert_equal(1, c_upd.count)
        c_upd.count = 0
      end

      text_entry.value = ''
      assert_equal(1, c_upd.count)
      c_upd.count = 0

      text_entry.change_value('bar')
      assert_equal(0, c_upd.count)

      text_entry.append_text('bar')
      assert_equal(1, c_upd.count)
      c_upd.count = 0

      text_entry.replace(3, 6, 'baz')
      assert_equal(1, c_upd.count)
      c_upd.count = 0

      text_entry.remove(0, 3)
      assert_equal(1, c_upd.count)
      c_upd.count = 0

      text_entry.write_text('foo')
      assert_equal(1, c_upd.count)
      c_upd.count = 0

      text_entry.clear
      assert_equal(1, c_upd.count)
      c_upd.count = 0

      text_entry.change_value('')
      assert_equal(0, c_upd.count)

      text_entry.change_value('non-empty')
      assert_equal(0, c_upd.count)

      text_entry.change_value('')
      assert_equal(0, c_upd.count)
    end
  end

end
