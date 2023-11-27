# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# 
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

require_relative './controlwithitems'

class Wx::ListBox
  alias :get_item_data :get_client_object
  alias :set_item_data :set_client_object
end
