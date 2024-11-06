# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
#
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

require_relative './enum'

module Wx

  class Orientation < Wx::Enum

    set_non_distinct(%i[ORIENTATION_MASK])

  end

  class Direction < Wx::Enum

    set_non_distinct(%i[TOP BOTTOM NORTH SOUTH WEST EAST ALL DIRECTION_MASK])

  end

  class Alignment < Wx::Enum

    set_non_distinct(%i[ALIGN_INVALID ALIGN_CENTRE_HORIZONTAL ALIGN_LEFT ALIGN_TOP ALIGN_CENTRE_VERTICAL ALIGN_CENTER ALIGN_MASK])

  end

  class SizerFlagBits < Wx::Enum

    set_non_distinct(%i[SIZER_FLAG_BITS_MASK])

  end

  class Stretch < Wx::Enum

    set_non_distinct(%i[GROW STRETCH_MASK])

  end

  class Border < Wx::Enum

    set_non_distinct(%i[BORDER_THEME BORDER_MASK])

  end

end
