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
    Director.Spec('Wx', 'wxColour', 'Colour').ignore(%w{
      wxColour::GetPixel wxTransparentColour wxColour::operator!=
      wxBLACK wxBLUE wxCYAN wxGREEN wxYELLOW wxLIGHT_GREY wxRED wxWHITE}),
    Director.Spec('Wx', 'wxObject', 'Object', director: Director::Object),
    Director.Spec('Wx', 'wxEvent', 'Event', %w{
      wxEvent wxCommandEvent wxIdleEvent wxNotifyEvent wxScrollEvent wxScrollWinEvent wxMouseEvent wxMouseState
      wxSetCursorEvent wxGestureEvent wxPanGestureEvent wxZoomGestureEvent wxRotateGestureEvent
      wxTwoFingerTapEvent wxLongPressEvent wxPressAndTapEvent wxKeyEvent wxKeyboardState
      wxSizeEvent wxMoveEvent wxPaintEvent wxEraseEvent wxFocusEvent wxActivateEvent
      wxInitDialogEvent wxMenuEvent wxCloseEvent wxShowEvent wxIconizeEvent wxMaximizeEvent
      wxFullScreenEvent wxJoystickEvent wxDropFilesEvent wxUpdateUIEvent wxSysColourChangedEvent
      wxMouseCaptureChangedEvent wxMouseCaptureLostEvent wxDisplayChangedEvent wxDPIChangedEvent
      wxPaletteChangedEvent wxQueryNewPaletteEvent wxNavigationKeyEvent wxWindowCreateEvent
      wxWindowDestroyEvent wxHelpEvent wxClipboardTextEvent wxContextMenuEvent}, director: Director::Event),
    Director.Spec('Wx', 'wxEvtHandler', 'EvtHandler', director: Director::EventHandler),
    Director.Spec('Wx', 'wxApp', 'App', %w{wxApp wxAppConsole}, director: Director::App),
    Director.Spec('Wx', 'wxDC', 'DC', director: Director::DC),
    Director.Spec('Wx', 'wxWindowDC', 'WindowDC').no_proxy('wxWindowDC'),
    Director.Spec('Wx', 'wxClientDC', 'ClientDC').no_proxy('wxClientDC'),
    Director.Spec('Wx', 'wxPaintDC', 'PaintDC').no_proxy('wxPaintDC'),
    Director.Spec('Wx', 'wxWindow', 'Window', director: Director::Window),
    Director.Spec('Wx', 'wxNonOwnedWindow', 'NonOwnedWindow', director: Director::Window).no_proxy('wxNonOwnedWindow'),
    Director.Spec('Wx', 'wxTopLevelWindow', 'TopLevelWindow', director: Director::TopLevelWindow),
    Director.Spec('Wx', 'wxFrame', 'Frame', director: Director::Frame),
    Director.Spec('Wx', 'wxGDIObject', 'GDIObject').make_abstract('wxGDIObject').no_proxy('wxGDIObject'),
    Director.Spec('Wx', 'wxBitmap', 'Bitmap', director: Director::Bitmap),
    Director.Spec('Wx', 'wxIcon', 'Icon').ignore('wxIcon::wxIcon(const char *const *)', 'wxIcon::wxIcon(const char[],int,int)'),
    Director.Spec('Wx', 'wxAcceleratorEntry', 'AcceleratorEntry', director: Director::AcceleratorEntry),
    Director.Spec('Wx', 'wxMenuItem', 'MenuItem').ignore(%w[wxMenuItem::GetLabel wxMenuItem::GetName wxMenuItem::GetText wxMenuItem::SetText wxMenuItem::GetLabelFromText]),
    Director.Spec('Wx', 'wxMenuBar', 'MenuBar', director: Director::Window)
      .no_proxy('wxMenuBar::Refresh',
                'wxMenuBar::FindItem',
                'wxMenuBar::Remove',
                'wxMenuBar::Replace')
      .ignore('wxMenuBar::wxMenuBar(size_t,wxMenu *[],const wxString[],long)',
              'wxMenuBar::GetLabelTop',
              'wxMenuBar::SetLabelTop'),
    Director.Spec('Wx', 'wxMenu', 'Menu', director: Director::Menu),
    Director.Spec('Wx', 'wxAboutDialogInfo', 'AboutDialogInfo')
      .include('wx/aboutdlg.h', 'wx/generic/aboutdlgg.h')
      .add_swig_interface_code('%typemap(check) wxWindow* parent "";'), # overrule common typemap to allow default NULL
    Director.Spec('Wx', 'wxDialog', 'Dialog', director: Director::TopLevelWindow)
      .ignore('wxDialog::GetContentWindow')
      .swig_import('include/defs.h'),
    Director.Spec('Wx', 'wxMessageDialog', 'MessageDialog', director: Director::TopLevelWindow),
    Director.Spec('Wx', 'wxSizerItem', 'SizerItem').disable_proxies.ignore(%w[wxSizerItem::SetSizer wxSizerItem::SetSpacer wxSizerItem::SetWindow]),
    Director.Spec('Wx', 'wxSizer', 'Sizer', director: Director::Sizer),
    Director.Spec('Wx', 'wxBoxSizer', 'BoxSizer', director: Director::Sizer),
    Director.Spec('Wx', 'wxControl', 'Control', director: Director::Window),
    Director.Spec('Wx', 'wxTextCtrl', 'TextCtrl', %w{wxTextCtrl wxTextEntry wxTextAttr}, director: Director::TextCtrl),
    Director.Spec('Wx', 'wxCheckBox', 'CheckBox', director: Director::Window),
    Director.Spec('Wx', 'wxAnyButton', 'AnyButton', director: Director::Window),
    Director.Spec('Wx', 'wxButton', 'Button', director: Director::Window),
    Director.Spec('Wx', 'wxToggleButton', 'ToggleButton', director: Director::Window).include('wx/tglbtn.h'),
    Director.Spec('Wx', 'wxControlWithItems', 'ControlWithItems', %w[wxControlWithItems wxItemContainer], director: Director::CtrlWithItems),
    Director.Spec('Wx', 'wxComboBox', 'ComboBox', %w{wxComboBox wxTextEntry}, director: Director::ComboBox),
  ]

end # module WXRuby3
