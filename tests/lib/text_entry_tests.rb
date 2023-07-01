
module TextEntryTests
  
  def do_text_entry_tests(control)
    if Wx.has_feature?(:USE_UIACTIONSIMULATOR)
      sim = Wx::UIActionSimulator.new

      updates = count_events(control, :evt_text) do |c_upd|
        maxlen_count = count_events(control, :evt_text_maxlen) do |c_maxlen|
          # set focus to control control
          control.set_focus
          Wx.get_app.yield

          sim.text('Hello')
          Wx.get_app.yield

          assert_equal('Hello', control.get_value)
          assert_equal(5, c_upd.count)

          control.set_max_length(10)
          sim.text('World')
          Wx.get_app.yield

          assert_equal('HelloWorld', control.get_value)
          assert_equal(10, c_upd.count)
          assert_equal(0, c_maxlen.count)

          sim.text('!')
          Wx.get_app.yield

          assert_equal('HelloWorld', control.get_value)
          assert_equal(10, c_upd.count)
          assert_equal(1, c_maxlen.count)
        end
      end
    end
  end
  
end
