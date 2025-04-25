# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

require_relative './lib/wxapp_runner'

class DialogTests < Test::Unit::TestCase

  class TestDialog < Wx::Dialog
    def initialize
      super()
    end
  end

  def test_dialog_inheritance
    dlg = TestDialog.new
    assert_kind_of(Wx::Dialog, dlg)
    assert_kind_of(Wx::Window, dlg)
    dlg.destroy
  end

  class  TestDialog2 < Wx::Dialog
    def initialize
      super(nil, -1,  'Test Dialog')

      sizer_top = Wx::VBoxSizer.new
      sizer_top.add(Wx::StaticText.new(self, label: 'Some text ...'))

      sizer_btn = Wx::HBoxSizer.new
      btn_focused = Wx::Button.new(self, -1, "Default button")
      btn_other = Wx::Button.new(self, -1, "&Another button")
      btn_close = Wx::Button.new(self, Wx::ID_CANCEL, "&Close")
      sizer_btn.add(btn_focused, 0, Wx::ALIGN_CENTER | Wx::ALL, 5)
      sizer_btn.add(btn_other, 0, Wx::ALIGN_CENTER | Wx::ALL, 5)
      sizer_btn.add(btn_close, 0, Wx::ALIGN_CENTER | Wx::ALL, 5)

      sizer_top.add(create_separated_sizer(sizer_btn))

      set_auto_layout(true)
      set_sizer(sizer_top)

      sizer_top.set_size_hints(self)
      sizer_top.fit(self)

      btn_focused.set_focus
      btn_focused.set_default
    end
  end

  def test_dialog_with_separated_sizer
    dlg = TestDialog2.new
    dlg.show(true)
    200.times { Wx.get_app.yield }
    sleep(2) unless is_ci_build?
    dlg.destroy
  end

  class TestDialog3 < Wx::Dialog
    def initialize
      super(nil, -1,  'Test Dialog')

      sizer_top = Wx::VBoxSizer.new
      sizer_top.add(Wx::StaticText.new(self, label: 'Some text ...'))
      sizer_top.add(create_separated_button_sizer(Wx::YES_NO|Wx::CANCEL))

      set_auto_layout(true)
      set_sizer(sizer_top)

      sizer_top.set_size_hints(self)
      sizer_top.fit(self)
    end
  end

  def test_dialog_with_button_sizer
    dlg = TestDialog3.new
    dlg.show(true)
    200.times { Wx.get_app.yield }
    sleep(2) unless is_ci_build?
    dlg.destroy
  end
end
