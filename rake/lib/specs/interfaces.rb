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
    Director.Spec('Wx', 'wxColour', 'Colour', %w{wxColour}).ignore(%w{
      wxColour::GetPixel wxTransparentColour wxColour::operator!=
      wxBLACK wxBLUE wxCYAN wxGREEN wxYELLOW wxLIGHT_GREY wxRED wxWHITE}),
    Director.Spec('Wx', 'wxObject', 'Object', %w{wxObject}, director: Director::Object),
    Director.Spec('Wx', 'wxEvent', 'Event', %w{
      wxEvent wxCommandEvent wxIdleEvent wxNotifyEvent wxScrollEvent wxScrollWinEvent wxMouseEvent
      wxSetCursorEvent wxGestureEvent wxPanGestureEvent wxZoomGestureEvent wxRotateGestureEvent
      wxTwoFingerTapEvent wxLongPressEvent wxPressAndTapEvent wxKeyEvent
      wxSizeEvent wxMoveEvent wxPaintEvent wxEraseEvent wxFocusEvent wxActivateEvent
      wxInitDialogEvent wxMenuEvent wxCloseEvent wxShowEvent wxIconizeEvent wxMaximizeEvent
      wxFullScreenEvent wxJoystickEvent wxDropFilesEvent wxUpdateUIEvent wxSysColourChangedEvent
      wxMouseCaptureChangedEvent wxMouseCaptureLostEvent wxDisplayChangedEvent wxDPIChangedEvent
      wxPaletteChangedEvent wxQueryNewPaletteEvent wxNavigationKeyEvent wxWindowCreateEvent
      wxWindowDestroyEvent wxHelpEvent wxClipboardTextEvent wxContextMenuEvent}, director: Director::Event),
    Director.Spec('Wx', 'wxEvtHandler', 'EvtHandler', %w{wxEvtHandler}, director: Director::EventHandler),
    Director.Spec('Wx', 'wxApp', 'App', %w{wxApp wxAppConsole}, director: Director::App),
    Director.Spec('Wx', 'wxDC', 'DC', %w{wxDC}, director: Director::DC),
    Director.Spec('Wx', 'wxWindowDC', 'WindowDC', %w{wxWindowDC}).no_proxy('wxWindowDC'),
    Director.Spec('Wx', 'wxClientDC', 'ClientDC', %w{wxClientDC}).no_proxy('wxClientDC'),
    Director.Spec('Wx', 'wxPaintDC', 'PaintDC', %w{wxPaintDC}).no_proxy('wxPaintDC'),
    Director.Spec('Wx', 'wxWindow', 'Window', %w{wxWindow}, director: Director::Window),
    Director.Spec('Wx', 'wxNonOwnedWindow', 'NonOwnedWindow', %w{wxNonOwnedWindow}, director: Director::Window).no_proxy('wxNonOwnedWindow'),
    Director.Spec('Wx', 'wxTopLevelWindow', 'TopLevelWindow', %w{wxTopLevelWindow}, director: Director::TopLevelWindow),
    Director.Spec('Wx', 'wxFrame', 'Frame', %w{wxFrame}, director: Director::Frame),
    Director.Spec('Wx', 'wxGDIObject', 'GDIObject', %w{wxGDIObject}).make_abstract('wxGDIObject').no_proxy('wxGDIObject'),
    Director.Spec('Wx', 'wxBitmap', 'Bitmap', %w{wxBitmap}, director: Director::Bitmap),
    Director.Spec('Wx', 'wxIcon', 'Icon', %w{wxIcon}).ignore('wxIcon::wxIcon(const char *const *)', 'wxIcon::wxIcon(const char[],int,int)'),
  ]

end # module WXRuby3
