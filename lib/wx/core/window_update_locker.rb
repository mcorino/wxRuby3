# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# 
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

# Emulates the wxWidgets WindowUpdateLocker class, by providing a scope within
# which window can be updated without refreshing

class Wx::WindowUpdateLocker
  # Only one class method accepting a window that will be
  # frozen while the block is executed
  def self.update(win)
    win.freeze
    yield
  ensure
    win.thaw
  end
end
