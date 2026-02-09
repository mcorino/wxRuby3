# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# 
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

module Wx

  if PLATFORM == 'WXOSX'
    GenericCalendarCtrl = CalendarCtrl
  end

end
