# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# 
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

require_relative './enum'

module Wx

  TheBrushList = Wx::Brush

  class BrushStyle < Wx::Enum

    set_non_distinct(%i[BRUSHSTYLE_INVALID BRUSHSTYLE_FIRST_HATCH BRUSHSTYLE_LAST_HATCH])

  end

end
