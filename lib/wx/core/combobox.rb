# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# 
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

require_relative './controlwithitems'

class Wx::ComboBox
  alias :get_item_data :get_client_data
  alias :set_item_data :set_client_data

  # Overload to provide Enumerator without block
  wx_each_string = instance_method :each_string
  define_method :each_string do |&block|
    if block
      wx_each_string.bind(self).call(&block)
    else
      ::Enumerator.new { |y| wx_each_string.bind(self).call { |ln, ix| y << [ln, ix] } }
    end
  end
end
