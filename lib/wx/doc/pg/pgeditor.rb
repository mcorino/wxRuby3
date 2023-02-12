
module Wx::PG

  # Standard property text editor
  PG_EDITOR_TEXT_CTRL = Wx::PG::PGEditor.get_standard_editor_class('TextCtrl')
  # Standard property text editor with custom editor dialog button
  PG_EDITOR_TEXT_CTRL_AND_BUTTON = Wx::PG::PGEditor.get_standard_editor_class('TextCtrlAndButton')
  # Standard choice property editor
  PG_EDITOR_CHOICE = Wx::PG::PGEditor.get_standard_editor_class('Choice')
  # Standard choice property editor with custom editor dialog button
  PG_EDITOR_CHOICE_AND_BUTTON = Wx::PG::PGEditor.get_standard_editor_class('ChoiceAndButton')
  # Standard checkbox property editor
  PG_EDITOR_CHECK_BOX = Wx::PG::PGEditor.get_standard_editor_class('CheckBox')
  # Standard combobox property editor
  PG_EDITOR_COMBO_BOX = Wx::PG::PGEditor.get_standard_editor_class('ComboBox')
  # Standard spin control property editor
  PG_EDITOR_SPIN_CTRL = Wx::PG::PGEditor.get_standard_editor_class('SpinCtrl')
  # Standard date picker property editor
  PG_EDITOR_DATE_PICKER_CTRL = Wx::PG::PGEditor.get_standard_editor_class('DatePickerCtrl')

end
