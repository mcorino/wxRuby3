# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

module Wx::PG

  Wx.add_delayed_constant(self, :PG_EDITOR_TEXT_CTRL) { Wx::PG::PropertyGrid.get_standard_editor_class('TextCtrl') }
  Wx.add_delayed_constant(self, :PG_EDITOR_TEXT_CTRL_AND_BUTTON) { Wx::PG::PropertyGrid.get_standard_editor_class('TextCtrlAndButton') }
  Wx.add_delayed_constant(self, :PG_EDITOR_CHOICE) { Wx::PG::PropertyGrid.get_standard_editor_class('Choice') }
  Wx.add_delayed_constant(self, :PG_EDITOR_CHOICE_AND_BUTTON) { Wx::PG::PropertyGrid.get_standard_editor_class('ChoiceAndButton') }
  Wx.add_delayed_constant(self, :PG_EDITOR_CHECK_BOX) { Wx::PG::PropertyGrid.get_standard_editor_class('CheckBox') }
  Wx.add_delayed_constant(self, :PG_EDITOR_COMBO_BOX) { Wx::PG::PropertyGrid.get_standard_editor_class('ComboBox') }
  Wx.add_delayed_constant(self, :PG_EDITOR_SPIN_CTRL) { Wx::PG::PropertyGrid.get_standard_editor_class('SpinCtrl') }
  Wx.add_delayed_constant(self, :PG_EDITOR_DATE_PICKER_CTRL) { Wx::PG::PropertyGrid.get_standard_editor_class('DatePickerCtrl') }

end
