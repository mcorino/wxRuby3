# Wx keyword ctor definitions for core classes
# Copyright (c) M.J.N. Corino, The Netherlands
# Adapted from wxRuby2.

# Window : base class for all widgets and frames
Wx::define_keyword_ctors(Wx::Window) do
   wx_ctor_params :id, :pos, :size, :style
   wx_ctor_params :name => 'window'
end

### FRAMES

# wxTopLevelWindow 	ABSTRACT: Any top level window, dialog or frame

# Normal frame
Wx::define_keyword_ctors(Wx::Frame) do
  wx_ctor_params :id, :title, :pos, :size, :style => Wx::DEFAULT_FRAME_STYLE
  wx_ctor_params :name => 'frame'
end

# MDI child frame
Wx::define_keyword_ctors(Wx::MDIChildFrame) do
  wx_ctor_params :id, :title, :pos, :size, :style => Wx::DEFAULT_FRAME_STYLE
  wx_ctor_params :name => 'frame'
end

# MDI parent frame
Wx::define_keyword_ctors(Wx::MDIParentFrame) do
  wx_ctor_params :id, :title, :pos, :size
  wx_ctor_params :style => Wx::DEFAULT_FRAME_STYLE|Wx::VSCROLL|Wx::HSCROLL
  wx_ctor_params :name => 'frame'
end

# wxMiniFrame 	A frame with a small title bar
Wx::define_keyword_ctors(Wx::MiniFrame) do
  wx_ctor_params :id, :title, :pos, :size
  wx_ctor_params :style =>  Wx::DEFAULT_FRAME_STYLE
  wx_ctor_params :name => 'frame'
end

# wxPropertySheetDialog 	Property sheet dialog
# wxTipWindow 	Shows text in a small window

# wxWizard 	A wizard dialog
Wx::define_keyword_ctors(Wx::Wizard) do
  wx_ctor_params :id
  wx_ctor_params :title
  wx_ctor_params :bitmap
  wx_ctor_params :pos # NB - no size argument for this class
  wx_ctor_params :style => Wx::DEFAULT_DIALOG_STYLE
end


# MISCELLANEOUS WINDOWS

# OpenGL Canvas
Wx::define_keyword_ctors('GLCanvas') do
  wx_ctor_params :id
  wx_ctor_params :pos, :size, :style => Wx::FULL_REPAINT_ON_RESIZE
  wx_ctor_params :name => 'GLCanvas'
  wx_ctor_params :attrib_list => [Wx::GL_RGBA, Wx::GL_DOUBLEBUFFER]
  wx_ctor_params :palette => Wx::NULL_PALETTE
end

# A window whose colour changes according to current user settings
Wx::define_keyword_ctors(Wx::Panel) do
  wx_ctor_params :id, :pos, :size, :style => Wx::TAB_TRAVERSAL
  wx_ctor_params :name => 'panel'
end

# wxScrolledWindow 	Window with automatically managed scrollbars
Wx::define_keyword_ctors(Wx::ScrolledWindow) do
  wx_ctor_params :id, :pos, :size, :style => Wx::VSCROLL|Wx::HSCROLL
  wx_ctor_params :name => 'scrolledWindow'
end

# Window which can be split vertically or horizontally
Wx::define_keyword_ctors(Wx::SplitterWindow) do
  wx_ctor_params :id, :pos, :size, :style => Wx::SP_3D
  wx_ctor_params :name => 'splitterWindow'
end

# Implements the status bar on a frame
Wx::define_keyword_ctors(Wx::StatusBar) do
  wx_ctor_params :id, :style => Wx::STB_SIZEGRIP
  wx_ctor_params :name => 'statusBar'
end

# Toolbar class
Wx::define_keyword_ctors(Wx::ToolBar) do
  wx_ctor_params :id, :pos, :size, :style => Wx::TB_HORIZONTAL|Wx::NO_BORDER
  wx_ctor_params :name => 'toolBar' # not as documented in Wx 2.6.3
end

# ToolBarTool class
Wx::define_keyword_ctors(Wx::ToolBarTool) do
  # By default we want Wx to generate an id for us, thus it doesn't
  # respect the wxWidgets default constructor value which is
  # ID_SEPARATOR
  wx_ctor_params :id => Wx::ID_ANY
  wx_ctor_params :label => ''
  wx_ctor_params :bitmap
  wx_ctor_params :disabled_bitmap => Wx::NULL_BITMAP
  wx_ctor_params :kind => Wx::ItemKind::ITEM_NORMAL
  wx_ctor_params :data => nil
  wx_ctor_params :short_help => ''
  wx_ctor_params :long_help => ''
end

# Similar to notebook but using choice control
Wx::define_keyword_ctors(Wx::Choicebook) do
  wx_ctor_params :id, :pos, :size, :style, :name => 'choiceBook'
end

# Notebook class
Wx::define_keyword_ctors(Wx::Notebook) do
  wx_ctor_params :id, :pos, :size, :style, :name => 'noteBook'
end

# Similar to notebook but using list control
Wx::define_keyword_ctors(Wx::Listbook) do
  wx_ctor_params :id, :pos, :size, :style, :name => 'listBook'
end

# Similar to notebook but using toolbar
Wx::define_keyword_ctors(Wx::Toolbook) do
  wx_ctor_params :id, :pos, :size, :style, :name => 'toolBook'
end

# Similar to notebook but using tree control
Wx::define_keyword_ctors(Wx::Treebook) do
  wx_ctor_params :id, :pos, :size, :style, :name => 'treeBook'
end

# wxSashWindow:	Window with four optional sashes that can be dragged
Wx::define_keyword_ctors(Wx::SashWindow) do
  wx_ctor_params :id, :pos, :size
  wx_ctor_params :style =>  Wx::CLIP_CHILDREN|Wx::SW_3D
  wx_ctor_params :name => 'sashWindow'
end

# wxSashLayoutWindow: Window that can be involved in an IDE-like layout
# arrangement
Wx::define_keyword_ctors(Wx::SashLayoutWindow) do
  wx_ctor_params :id, :pos, :size
  wx_ctor_params :style =>  Wx::CLIP_CHILDREN|Wx::SW_3D
  wx_ctor_params :name => 'layoutWindow'
end

# wxVScrolledWindow: As wxScrolledWindow but supports lines of variable height

# wxWizardPage: A base class for the page in wizard dialog.
Wx::define_keyword_ctors(Wx::WizardPage) do
  wx_ctor_params :bitmap => Wx::NULL_BITMAP
end

# wxWizardPageSimple: A page in wizard dialog.
Wx::define_keyword_ctors(Wx::WizardPageSimple) do
  wx_ctor_params :prev => nil
  wx_ctor_params :next => nil
  wx_ctor_params :bitmap
end

### DIALOGS
# wxDialog 	Base class for common dialogs
Wx::define_keyword_ctors(Wx::Dialog) do
  wx_ctor_params :id, :title => ''
  wx_ctor_params :pos, :size, :style => Wx::DEFAULT_DIALOG_STYLE
  wx_ctor_params :name => 'dialogBox'
end

# wxColourDialog 	Colour chooser dialog
Wx::define_keyword_ctors(Wx::ColourDialog) do
  wx_ctor_params :colour_data => nil
end

# wxDirDialog 	Directory selector dialog
Wx::define_keyword_ctors(Wx::DirDialog) do
  wx_ctor_params :message => 'Choose a directory'
  wx_ctor_params :default_path => ''
  wx_ctor_params :style => Wx::DD_DEFAULT_STYLE
  wx_ctor_params :pos, :size, :name => 'wxDirCtrl'
end

# wxFileDialog 	File selector dialog
Wx::define_keyword_ctors(Wx::FileDialog) do
  wx_ctor_params :message => 'Choose a file'
  wx_ctor_params :default_dir  => ''
  wx_ctor_params :default_file => ''
  wx_ctor_params :wildcard => '*.*'
  wx_ctor_params :style => Wx::FD_DEFAULT_STYLE
  wx_ctor_params :pos, :size, :name => 'filedlg'
end

# wxFindReplaceDialog 	Text search/replace dialog
Wx::define_keyword_ctors(Wx::FindReplaceDialog) do
  wx_ctor_params :find_replace_data => Wx::FindReplaceData.new()
  wx_ctor_params :title => 'findReplaceDialog'
  wx_ctor_params :style
end

# Dialog to get one or more selections from a list
Wx::define_keyword_ctors(Wx::MultiChoiceDialog) do
  wx_ctor_params :message => ''
  wx_ctor_params :caption => ''
  wx_ctor_params :choices => []
  wx_ctor_params :style => Wx::DEFAULT_DIALOG_STYLE|Wx::RESIZE_BORDER|
                           Wx::OK|Wx::CANCEL|Wx::CENTRE
  wx_ctor_params :pos
end

# Dialog to get a single selection from a list and return the string
Wx::define_keyword_ctors(Wx::SingleChoiceDialog) do
  wx_ctor_params :message => ''
  wx_ctor_params :caption => ''
  wx_ctor_params :choices => []
  wx_ctor_params :data => nil
  wx_ctor_params :style => Wx::DEFAULT_DIALOG_STYLE|Wx::RESIZE_BORDER|
                           Wx::OK|Wx::CANCEL|Wx::CENTRE
  wx_ctor_params :pos
end

# Dialog to get a single line of text from the user
Wx::define_keyword_ctors(Wx::TextEntryDialog) do
  wx_ctor_params :message => ''
  wx_ctor_params :caption => 'Please enter text'
  wx_ctor_params :default_value => ''
  wx_ctor_params :style => Wx::OK|Wx::CANCEL|Wx::CENTRE
  wx_ctor_params :pos
end

# wxPasswordEntryDialog 	Dialog to get a password from the user
Wx::define_keyword_ctors(Wx::PasswordEntryDialog) do
  wx_ctor_params :message => ''
  wx_ctor_params :caption => 'Enter password'
  wx_ctor_params :default_value => ''
  wx_ctor_params :style => Wx::OK|Wx::CANCEL|Wx::CENTRE
  wx_ctor_params :pos
end

# wxFontDialog 	Font chooser dialog
# wxPageSetupDialog 	Standard page setup dialog

# Simple message box dialog
Wx::define_keyword_ctors(Wx::MessageDialog) do
  wx_ctor_params :message => ''
  wx_ctor_params :caption => 'Message box'
  wx_ctor_params :style => Wx::OK|Wx::CANCEL
  wx_ctor_params :pos
end

# Property editing dialog
Wx::define_keyword_ctors(Wx::PropertySheetDialog) do
  wx_ctor_params :id, :title
  wx_ctor_params :pos, :size, :style => Wx::DEFAULT_DIALOG_STYLE
  wx_ctor_params :name => 'propertySheetDialog'
end

### CONTROLS

# Push button control, displaying text
Wx::define_keyword_ctors(Wx::Button) do
  wx_ctor_params :id, :label => ''
  wx_ctor_params :pos, :size, :style
  wx_ctor_params :validator, :name => 'button'
end

# Push button control, displaying a bitmap
Wx::define_keyword_ctors(Wx::BitmapButton) do
  wx_ctor_params :id
  wx_ctor_params :bitmap
  wx_ctor_params :pos, :size, :style => Wx::BU_AUTODRAW
  wx_ctor_params :validator, :name => 'button'
end

# A button which stays pressed when clicked by user.
Wx::define_keyword_ctors(Wx::ToggleButton) do
  wx_ctor_params :id, :label, :pos, :size, :style
  wx_ctor_params :validator, :name => 'checkBox'
end

# Control showing an entire calendar month
Wx::define_keyword_ctors(Wx::CalendarCtrl) do
  wx_ctor_params :id, :date => Time.now()
  wx_ctor_params :pos, :size, :style => Wx::CAL_SHOW_HOLIDAYS
  wx_ctor_params :name => 'calendar'
end

# 	Checkbox control
Wx::define_keyword_ctors(Wx::CheckBox) do
  wx_ctor_params :id, :label => ''
  wx_ctor_params :pos, :size, :style
  wx_ctor_params :validator, :name => 'checkBox'
end

# wxListBox 	A list of strings for single or multiple selection
Wx::define_keyword_ctors(Wx::ListBox) do
  wx_ctor_params :id, :pos, :size, :choices => []
  wx_ctor_params :style
  wx_ctor_params :validator, :name => 'listBox'
end

# A listbox with a checkbox to the left of each item
Wx::define_keyword_ctors(Wx::CheckListBox) do
  wx_ctor_params :id, :pos, :size, :choices, :style
  wx_ctor_params :validator, :name => 'listBox'
end

# wxChoice 	Choice control (a combobox without the editable area)
Wx::define_keyword_ctors(Wx::Choice) do
  wx_ctor_params :id, :pos, :size, :choices, :style
  wx_ctor_params :validator, :name => 'choice'
end

# wxComboBox 	A choice with an editable area
Wx::define_keyword_ctors(Wx::ComboBox) do
  wx_ctor_params :id, :value => ''
  wx_ctor_params :pos, :size, :choices => []
  wx_ctor_params :style
  wx_ctor_params :validator, :name => 'comboBox'
end

# wxBitmapComboBox 	A choice with an editable area
Wx::define_keyword_ctors(Wx::BitmapComboBox) do
  wx_ctor_params :id, :value => ''
  wx_ctor_params :pos, :size, :choices => []
  wx_ctor_params :style
  wx_ctor_params :validator, :name => 'comboBox'
end

# wxDatePickerCtrl 	Small date picker control

# wxGauge 	A control to represent a varying quantity, such as time
# remaining
Wx::define_keyword_ctors(Wx::Gauge) do
  wx_ctor_params :id, :range, :pos, :size, :style => Wx::GA_HORIZONTAL
  wx_ctor_params :validator, :name => 'gauge'
end

# wxGenericDirCtrl 	A control for displaying a directory tree
Wx::define_keyword_ctors(Wx::GenericDirCtrl) do
  # TODO :dir => Wx::DIR_DIALOG_DEFAULT_FOLDER_STR
  wx_ctor_params :id, :dir => ''
  wx_ctor_params :pos, :size,
                 :style => Wx::DIRCTRL_3D_INTERNAL|Wx::SUNKEN_BORDER
  wx_ctor_params :filter => ''
  wx_ctor_params :default_filter => 0
  wx_ctor_params :name => 'genericDirCtrl'
end

# wxListCtrl 	A control for displaying lists of strings and/or icons, plus a multicolumn report view
Wx::define_keyword_ctors(Wx::ListCtrl) do
  wx_ctor_params :id, :pos, :size, :style => Wx::LC_ICON
  wx_ctor_params :validator, :name => 'listCtrl'
end

# wxListView 	A simpler interface (facade for wxListCtrl in report mode

# wxTreeCtrl 	Tree (hierarchy) control
Wx::define_keyword_ctors(Wx::TreeCtrl) do
  wx_ctor_params :id, :pos, :size, :style => Wx::TR_DEFAULT_STYLE
  wx_ctor_params :validator, :name => 'treeCtrl'
end

# wxSpinCtrl 	A spin control - i.e. spin button and text control
Wx::define_keyword_ctors(Wx::SpinCtrl) do
  wx_ctor_params :id, :value => ''
  wx_ctor_params :pos, :size, :style => Wx::SP_ARROW_KEYS
  wx_ctor_params :min => 0
  wx_ctor_params :max => 100
  wx_ctor_params :initial => 0
  wx_ctor_params :name => 'spinCtrl'
end

# One or more lines of non-editable text
Wx::define_keyword_ctors(Wx::StaticText) do
  wx_ctor_params :id, :label, :pos, :size, :style, :name => 'staticText'
end

Wx::define_keyword_ctors(Wx::StaticBox) do
  wx_ctor_params :id, :label, :pos, :size, :style, :name => 'staticBox'
end

Wx::define_keyword_ctors(Wx::StaticLine) do
  wx_ctor_params :id, :pos, :size, :style => Wx::LI_HORIZONTAL
  wx_ctor_params :name => 'staticBox'
end

# wxStaticBitmap 	A control to display a bitmap
Wx::define_keyword_ctors(Wx::StaticBitmap) do
  wx_ctor_params :id
  # autoconvert Bitmaps to BitmapBundles for downward compatibility
  wx_ctor_params :label
  wx_ctor_params :pos, :size, :style, :name => Wx::StaticBitmapNameStr
end


# wxRadioBox 	A group of radio buttons
Wx::define_keyword_ctors(Wx::RadioBox) do
  wx_ctor_params :id, :label => ''
  wx_ctor_params :pos, :size, :choices => []
  wx_ctor_params :major_dimension => 0
  wx_ctor_params :style => Wx::RA_SPECIFY_COLS
  wx_ctor_params :validator, :name => 'radioBox'
end

# wxRadioButton: A round button used with others in a mutually exclusive way
Wx::define_keyword_ctors(Wx::RadioButton) do
  wx_ctor_params :id, :label => ''
  wx_ctor_params :pos, :size, :style => 0
  wx_ctor_params :validator, :name => 'radioButton'
end

# wxSlider 	A slider that can be dragged by the user
Wx::define_keyword_ctors(Wx::Slider) do
  wx_ctor_params :id, :value => 0
  wx_ctor_params :min_value, :max_value
  wx_ctor_params :pos, :size, :style => Wx::SL_HORIZONTAL
  wx_ctor_params :validator, :name => 'slider'
end

# wxSpinButton - Has two small up and down (or left and right) arrow buttons
Wx::define_keyword_ctors(Wx::SpinButton) do
   wx_ctor_params :id, :pos, :size, :style => Wx::SP_HORIZONTAL
   wx_ctor_params :name => 'spinButton'
end

# wxScrollBar - standalone scrollbar with arrows and thumb
Wx::define_keyword_ctors(Wx::ScrollBar) do
   wx_ctor_params :id, :pos, :size, :style => Wx::SB_HORIZONTAL
   wx_ctor_params :validator, :name => 'scrollBar'
end


# wxVListBox 	A listbox supporting variable height rows

# wxTextCtrl 	Single or multiline text editing control
Wx::define_keyword_ctors(Wx::TextCtrl) do
  wx_ctor_params :id, :value => ''
  wx_ctor_params :pos, :size, :style
  wx_ctor_params :validator, :name => 'textCtrl'
end

# wxHyperTextCtrl - display a clickable URL
Wx::define_keyword_ctors(Wx::HyperlinkCtrl) do
  wx_ctor_params :id, :label => ''
  wx_ctor_params :url => ''
  wx_ctor_params :pos, :size, :style => Wx::HL_DEFAULT_STYLE
  wx_ctor_params :name => 'hyperlink'
end

Wx::define_keyword_ctors(Wx::CollapsiblePane) do
  wx_ctor_params :id, :label => ''
  wx_ctor_params :pos, :size, :style => 0
  wx_ctor_params :validator, :name => 'collapsiblePane'
end

Wx::define_keyword_ctors(Wx::MediaCtrl) do
  wx_ctor_params :id, :filename => ''
  wx_ctor_params :pos, :size, :style => 0
  wx_ctor_params :backend => ''
  wx_ctor_params :validator, :name => 'mediaCtrl'
end if Wx.has_feature?(:USE_MEDIACTRL)

Wx::define_keyword_ctors(Wx::SearchCtrl) do
  wx_ctor_params :id, :value => ''
  wx_ctor_params :pos, :size, :style => 0
  wx_ctor_params :validator, :name => 'searchCtrl'
end

Wx::define_keyword_ctors(Wx::AnimationCtrl) do
  wx_ctor_params :id, :anim
  wx_ctor_params :pos, :size, :style => Wx::AC_DEFAULT_STYLE
  wx_ctor_params :name => 'animationCtrl'
end

Wx::define_keyword_ctors(Wx::VScrolledWindow) do
  wx_ctor_params :id, :pos, :size, :style, :name => 'VScrolledWindowNameStr'
end

Wx::define_keyword_ctors(Wx::VListBox) do
  wx_ctor_params :id, :pos, :size, :style, :name => 'VListBoxNameStr'
end

Wx::define_keyword_ctors(Wx::DatePickerCtrl) do
  wx_ctor_params :id, :dt, :pos, :size, :style, :validator, :name => 'dateCtrl'
end

Wx::define_keyword_ctors(Wx::ActivityIndicator) do
  wx_ctor_params :id, :pos, :size, :style => Wx::AC_DEFAULT_STYLE
  wx_ctor_params :name => 'activityIndicator'
end

Wx::define_keyword_ctors(Wx::BannerWindow) do
  wx_ctor_params :id, :dir => Wx::Direction::LEFT
  wx_ctor_params :pos, :size, :style
  wx_ctor_params :name => 'bannerwindow'
end

# FIXME - SymbolPickerDialog is hard to because the parent argument is
# in a strange place.
