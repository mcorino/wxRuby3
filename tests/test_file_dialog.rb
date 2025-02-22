# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

require_relative './lib/wxapp_runner'

class FileDialogTests < Test::Unit::TestCase

  def dialog_tester(dlg, rc=Wx::ID_OK)
    if Wx::PLATFORM == 'WXGTK'
      timer = Wx::Timer.new(dlg)
      dlg.evt_timer(timer) { dlg.end_modal(rc) }
      timer.start_once(2000)
      dlg.show_modal
    else
      rc
    end
  end

  # temporary as wxw >= 3.3.0 introduced a bug
  if Wx::WXWIDGETS_VERSION < '3.3.0'
  def test_file_dialog
    dlg = Wx::FileDialog.new(nil, 'Select file')
    assert_kind_of(Wx::FileDialog, dlg)
    assert_kind_of(Wx::Dialog, dlg)
    assert_kind_of(Wx::Window, dlg)
    assert_equal(Wx::ID_OK, dialog_tester(dlg))
  end
  end

  class FileDialogTestCustomization < Wx::FileDialogCustomizeHook

    def initialize
      super
      @hooked = Wx::PLATFORM != 'WXGTK'
    end

    attr_reader :hooked

    def add_custom_controls(customizer)
      @hooked = true
      btn_ctrl = customizer.add_button('Custom Button')
    end

  end

  def test_customized_file_dialog
    dlg = Wx::FileDialog.new(nil, 'Select file')
    hook = FileDialogTestCustomization.new
    dlg.set_customize_hook(hook)
    GC.start
    assert_equal(Wx::ID_OK, dialog_tester(dlg))
    GC.start
    assert_true(hook.hooked)
    GC.start
  end

end
