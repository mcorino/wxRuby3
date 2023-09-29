# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# 
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

module Wx

  module TextEntry

    wx_auto_complete = instance_method :auto_complete
    define_method :auto_complete do |completer|
      if wx_auto_complete.bind(self).call(completer)
        @completer = completer # keep the Ruby object alive
      end
    end

  end

end
