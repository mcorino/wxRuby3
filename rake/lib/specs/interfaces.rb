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
    Director.Spec('Wx', 'wxApp', 'App', %w{wxApp wxAppConsole}, director: Director::App),
    Director.Spec('Wx', 'wxClientDC', 'ClientDC', %w{wxClientDC}),
    Director.Spec('Wx', 'wxDC', 'DC', %w{wxDC}, director: Director::DC),
  ]

end # module WXRuby3
