# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# 
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

# Base class for providing context-sensitive help. The main definition
# is in SWIG/C++

class Wx::HelpProvider
  class << self
    # We need to protect the currently set HelpProvider from GC as it is a
    # SWIG Director; it can't be reaped and re-wrapped later. The
    # easiest way is to make the currently set one an instance variable
    # of this class
    wx_set = instance_method :set
    wx_redefine_method(:set) do | help_provider |
      wx_set.bind(self).call(help_provider)
      @__hp__ = help_provider
    end
  end
end
