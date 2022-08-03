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
    Director.Spec('Wx', 'wxDefs', 'Defs', ['defs.h'], director: Director::Defs),
    Director.Spec('Wx', 'wxObject', 'Object', %w{wxObject}, director: Director::Object),
    Director.Spec('Wx', 'wxEvtHandler', 'EvtHandler', %w{wxEvtHandler}, director: Director::EventHandler),
    Director.Spec('Wx', 'wxApp', 'App', %w{wxApp wxAppConsole}, director: Director::App),
    Director.Spec('Wx', 'wxDC', 'DC', %w{wxDC}, director: Director::DC),
    Director.Spec('Wx', 'wxWindowDC', 'WindowDC', %w{wxWindowDC}),
    Director.Spec('Wx', 'wxClientDC', 'ClientDC', %w{wxClientDC}),
    Director.Spec('Wx', 'wxWindow', 'Window', %w{wxWindow}, director: Director::Window),
    Director.Spec('Wx', 'wxNonOwnedWindow', 'NonOwnedWindow', %w{wxNonOwnedWindow}, director: Director::Window),
    Director.Spec('Wx', 'wxTopLevelWindow', 'TopLevelWindow', %w{wxTopLevelWindow}, director: Director::TopLevelWindow),
    Director.Spec('Wx', 'wxFrame', 'Frame', %w{wxFrame}, director: Director::Frame),
  ]

end # module WXRuby3
