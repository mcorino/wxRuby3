# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# 
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

require_relative './enum'

module Wx

  ThePenList = Wx::Pen

  class PenStyle < Wx::Enum

    set_non_distinct(%i[PENSTYLE_INVALID PENSTYLE_FIRST_HATCH PENSTYLE_LAST_HATCH])

  end

  class PenJoin < Wx::Enum

    set_non_distinct(%i[JOIN_INVALID])

  end

  class PenCap < Wx::Enum

    set_non_distinct(%i[CAP_INVALID])

  end

end
