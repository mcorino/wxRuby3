# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# 
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

module Wx

  class PlatformInfo

    # make all methods of the singleton accessible through the class
    def self.method_missing(sym, *args)
      Wx::PlatformInfo.instance.__send__(sym, *args)
    end

  end

end
