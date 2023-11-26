# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# 
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

require_relative './controlwithitems'

module Wx

  class ComboBox

    # redefine #clear method to take care of client data and to call the proper #clear_items method
    # (not the #clear method inherited from the TextEntry mixin)
    wx_clear = instance_method :clear_items
    define_method :clear do
      wx_clear.bind(self).call
    end

  end

end
