#--------------------------------------------------------------------
# @file    interfaces.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface generation specs
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

module WXRuby3

  SPECIFICATIONS = [
    Director.Spec('Wx', 'defs', 'Defs', ['defs.h'], director: Director::Defs),
    Director.Spec('Wx', 'wxGDICommon', 'GDICommon', %w{wxPoint wxSize wxRect wxRealPoint wxColourDatabase}, director: Director::GDICommon),
    Director.Spec('Wx', 'wxColour', 'Colour', director: Director::Colour),
    Director.Spec('Wx', 'wxObject', 'Object', director: Director::Object),
    Director.Spec('Wx', 'wxEvent', 'Event', director: Director::Event),
    Director.Spec('Wx', 'wxEvtHandler', 'EvtHandler', director: Director::EventHandler),
    Director.Spec('Wx', 'wxApp', 'App', %w{wxApp wxAppConsole}, director: Director::App),
    Director.Spec('Wx', 'wxDC', 'DC', director: Director::DC),
    Director.Spec('Wx', 'wxWindowDC', 'WindowDC'),
    Director.Spec('Wx', 'wxClientDC', 'ClientDC'),
    Director.Spec('Wx', 'wxPaintDC', 'PaintDC'),
    Director.Spec('Wx', 'wxMemoryDC', 'MemoryDC'),
    Director.Spec('Wx', 'wxWindow', 'Window', director: Director::Window),
    Director.Spec('Wx', 'wxNonOwnedWindow', 'NonOwnedWindow', director: Director::Window).no_proxy('wxNonOwnedWindow'),
    Director.Spec('Wx', 'wxTopLevelWindow', 'TopLevelWindow', director: Director::TopLevelWindow),
    Director.Spec('Wx', 'wxFrame', 'Frame', director: Director::Frame),
    Director.Spec('Wx', 'wxGDIObject', 'GDIObject').make_abstract('wxGDIObject').no_proxy('wxGDIObject'),
    Director.Spec('Wx', 'wxIconLocation', 'IconLocation'),
    Director.Spec('Wx', 'wxMask', 'Mask'),
    Director.Spec('Wx', 'wxBitmap', 'Bitmap', director: Director::Bitmap),
    Director.Spec('Wx', 'wxIcon', 'Icon', director: Director::Icon),
    Director.Spec('Wx', 'wxAcceleratorEntry', 'AcceleratorEntry', director: Director::AcceleratorEntry),
    Director.Spec('Wx', 'wxMenuItem', 'MenuItem', director: Director::MenuItem),
    Director.Spec('Wx', 'wxMenuBar', 'MenuBar', director: Director::MenuBar),
    Director.Spec('Wx', 'wxMenu', 'Menu', director: Director::Menu),
    Director.Spec('Wx', 'wxAboutDialogInfo', 'AboutDialogInfo', director: Director::AboutDialogInfo),
    Director.Spec('Wx', 'wxDialog', 'Dialog', director: Director::Dialog),
    Director.Spec('Wx', 'wxMessageDialog', 'MessageDialog', director: Director::TopLevelWindow),
    Director.Spec('Wx', 'wxSizerItem', 'SizerItem').disable_proxies.ignore(%w[wxSizerItem::SetSizer wxSizerItem::SetSpacer wxSizerItem::SetWindow]),
    Director.Spec('Wx', 'wxSizer', 'Sizer', director: Director::Sizer),
    Director.Spec('Wx', 'wxBoxSizer', 'BoxSizer', director: Director::Sizer),
    Director.Spec('Wx', 'wxControl', 'Control', director: Director::Window),
    Director.Spec('Wx', 'wxTextCtrl', 'TextCtrl', %w{wxTextCtrl wxTextEntry wxTextAttr}, director: Director::TextCtrl),
    Director.Spec('Wx', 'wxCheckBox', 'CheckBox', director: Director::Window),
    Director.Spec('Wx', 'wxAnyButton', 'AnyButton', director: Director::Window),
    Director.Spec('Wx', 'wxButton', 'Button', director: Director::Button),
    Director.Spec('Wx', 'wxToggleButton', 'ToggleButton', director: Director::Window).include('wx/tglbtn.h'),
    Director.Spec('Wx', 'wxControlWithItems', 'ControlWithItems', %w[wxControlWithItems wxItemContainer wxItemContainerImmutable], director: Director::CtrlWithItems),
    Director.Spec('Wx', 'wxComboBox', 'ComboBox', %w{wxComboBox wxTextEntry}, director: Director::ComboBox),
    Director.Spec('Wx', 'wxRadioBox', 'RadioBox', director: Director::RadioBox),
    Director.Spec('Wx', 'wxPanel', 'Panel', director: Director::Window),
    Director.Spec('Wx', 'wxBookCtrlEvent', 'BookCtrlEvent', director: Director::BookCtrlEvent),
    Director.Spec('Wx', 'wxBookCtrlBase', 'BookCtrlBase', %w[wxBookCtrlBase wxWithImages], director: Director::BookCtrls),
    Director.Spec('Wx', 'wxNotebook', 'Notebook', director: Director::BookCtrls),
    Director.Spec('Wx', 'wxImageList', 'ImageList').rename('AddIcon' => 'wxImageList::Add(const wxIcon& icon)'),
    Director.Spec('Wx', 'wxListBox', 'ListBox', director: Director::ListBox),
    Director.Spec('Wx', 'wxChoice', 'Choice', director: Director::Choice),
    Director.Spec('Wx', 'wxStaticBox', 'StaticBox', director: Director::Window),
    Director.Spec('Wx', 'wxGauge', 'Gauge', director: Director::Window),
    Director.Spec('Wx', 'wxSlider', 'Slider', director: Director::Window),
    Director.Spec('Wx', 'wxStaticText', 'StaticText', director: Director::Window),
    Director.Spec('Wx', 'wxSpinButton', 'SpinButton', director: Director::Window),
    Director.Spec('Wx', 'wxSpinEvent', 'SpinEvent', director: Director::SpinEvent),
    Director.Spec('Wx', 'wxSpinCtrl', 'SpinCtrl', director: Director::Window),
    Director.Spec('Wx', 'wxStaticBitmap', 'StaticBitmap', director: Director::StaticBitmap),
    Director.Spec('Wx', 'wxBitmapButton', 'BitmapButton', director: Director::Button),
    Director.Spec('Wx', 'wxArtProvider', 'ArtProvider', director: Director::ArtProvider),
    Director.Spec('Wx', 'wxStaticBoxSizer', 'StaticBoxSizer', director: Director::Sizer),
    Director.Spec('Wx', 'wxCursor', 'Cursor', director: Director::Cursor),
    Director.Spec('Wx', 'wxRadioButton', 'RadioButton', director: Director::Window),
    Director.Spec('Wx', 'wxToolTip', 'ToolTip', director: Director::TooTip),
    Director.Spec('Wx', 'wxLog', 'Log', director: Director::Log),
  ]

end # module WXRuby3
