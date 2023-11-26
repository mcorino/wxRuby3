# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# 
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

# Superclass of a variety of controls that display lists of items (eg
# Choice, ListBox, CheckListBox)

class Wx::ControlWithItems

  alias :get_client_data :get_client_object
  alias :set_client_data :set_client_object

  # Overload to provide Enumerator without block
  wx_each_string = instance_method :each_string
  define_method :each_string do |&block|
    if block
      wx_each_string.bind(self).call(&block)
    else
      ::Enumerator.new { |y| wx_each_string.bind(self).call { |ln| y << ln } }
    end
  end

end
