# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# 
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

class Wx::VListBox

  wx_each_selected = instance_method :each_selected
  define_method :each_selected do |&block|
    if block
      wx_each_selected.bind(self).call(&block)
    else
      ::Enumerator.new { |y| wx_each_selected.bind(self).call { |sel| y << sel } }
    end
  end

end
