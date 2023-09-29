# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx

  # Equivalent to Wx::SystemSettings.get_font(Wx::SystemFont::SYS_DEFAULT_GUI_FONT)
  NORMAL_FONT = Wx::SystemSettings.get_font(Wx::SystemFont::SYS_DEFAULT_GUI_FONT)
  # A font using the Wx::FONTFAMILY_SWISS family and 2 points smaller than Wx::NORMAL_FONT.
  SMALL_FONT = Wx::Font.new
  # A font using the Wx::FONTFAMILY_ROMAN family and wxFONTSTYLE_ITALIC style and of the same size of Wx::NORMAL_FONT.
  ITALIC_FONT = Wx::Font.new
  # A font identic to Wx::NORMAL_FONT except for the family used which is Wx::FONTFAMILY_SWISS.
  SWISS_FONT = Wx::Font.new

  # Red pen.
  # Except for the color it has all standard attributes (1-pixel width, Wx::PENSTYLE_SOLID and Wx::CAP_ROUND styles, etc...).
  RED_PEN = Wx::Pen.new
  # Cyan pen.
  # Except for the color it has all standard attributes (1-pixel width, Wx::PENSTYLE_SOLID and Wx::CAP_ROUND styles, etc...).
  CYAN_PEN = Wx::Pen.new
  # Green pen.
  # Except for the color it has all standard attributes (1-pixel width, Wx::PENSTYLE_SOLID and Wx::CAP_ROUND styles, etc...).
  GREEN_PEN = Wx::Pen.new
  # Black pen.
  # Except for the color it has all standard attributes (1-pixel width, Wx::PENSTYLE_SOLID and Wx::CAP_ROUND styles, etc...).
  BLACK_PEN = Wx::Pen.new
  # White pen.
  # Except for the color it has all standard attributes (1-pixel width, Wx::PENSTYLE_SOLID and Wx::CAP_ROUND styles, etc...).
  WHITE_PEN = Wx::Pen.new
  # Transparent pen.
  # Except for the color it has all standard attributes (1-pixel width, Wx::PENSTYLE_SOLID and Wx::CAP_ROUND styles, etc...).
  TRANSPARENT_PEN = Wx::Pen.new
  # Black dashed pen.
  # Except for the color and for the Wx::PENSTYLE_SHORT_DASH it has all standard attributes (1-pixel width, Wx::CAP_ROUND style, etc...).
  BLACK_DASHED_PEN = Wx::Pen.new
  # Grey pen.
  # Except for the color it has all standard attributes (1-pixel width, Wx::PENSTYLE_SOLID and Wx::CAP_ROUND styles, etc...).
  GREY_PEN = Wx::Pen.new
  # Medium-grey pen.
  # Except for the color it has all standard attributes (1-pixel width, Wx::PENSTYLE_SOLID and Wx::CAP_ROUND styles, etc...).
  MEDIUM_GREY_PEN = Wx::Pen.new
  # Light-grey pen.
  # Except for the color it has all standard attributes (1-pixel width, Wx::PENSTYLE_SOLID and Wx::CAP_ROUND styles, etc...).
  LIGHT_GREY_PEN = Wx::Pen.new
  # Yellow pen.
  # Except for the color it has all standard attributes (1-pixel width, Wx::PENSTYLE_SOLID and Wx::CAP_ROUND styles, etc...).
  YELLOW_PEN = Wx::Pen.new

  # Blue brush
  # Except for the color it has all standard attributes (Wx::BRUSHSTYLE_SOLID, no stipple bitmap, etc...).
  BLUE_BRUSH = Wx::Brush.new
  # Green brush
  # Except for the color it has all standard attributes (Wx::BRUSHSTYLE_SOLID, no stipple bitmap, etc...).
  GREEN_BRUSH = Wx::Brush.new
  # White brush
  # Except for the color it has all standard attributes (Wx::BRUSHSTYLE_SOLID, no stipple bitmap, etc...).
  WHITE_BRUSH = Wx::Brush.new
  # Black brush
  # Except for the color it has all standard attributes (Wx::BRUSHSTYLE_SOLID, no stipple bitmap, etc...).
  BLACK_BRUSH = Wx::Brush.new
  # Grey brush
  # Except for the color it has all standard attributes (Wx::BRUSHSTYLE_SOLID, no stipple bitmap, etc...).
  GREY_BRUSH = Wx::Brush.new
  # Medium-grey brush
  # Except for the color it has all standard attributes (Wx::BRUSHSTYLE_SOLID, no stipple bitmap, etc...).
  MEDIUM_GREY_BRUSH = Wx::Brush.new
  # Light-grey brush
  # Except for the color it has all standard attributes (Wx::BRUSHSTYLE_SOLID, no stipple bitmap, etc...).
  LIGHT_GREY_BRUSH = Wx::Brush.new
  # Transparent brush
  # Except for the color it has all standard attributes (Wx::BRUSHSTYLE_SOLID, no stipple bitmap, etc...).
  TRANSPARENT_BRUSH = Wx::Brush.new
  # Cyan brush
  # Except for the color it has all standard attributes (Wx::BRUSHSTYLE_SOLID, no stipple bitmap, etc...).
  CYAN_BRUSH = Wx::Brush.new
  # Red brush
  # Except for the color it has all standard attributes (Wx::BRUSHSTYLE_SOLID, no stipple bitmap, etc...).
  RED_BRUSH = Wx::Brush.new
  # Yellow brush
  # Except for the color it has all standard attributes (Wx::BRUSHSTYLE_SOLID, no stipple bitmap, etc...).
  YELLOW_BRUSH = Wx::Brush.new

  # Standard cursor
  STANDARD_CURSOR = Wx::Cursor.new
  # Hourglass cursor
  HOURGLASS_CURSOR = Wx::Cursor.new
  # Crosshair cursor
  CROSS_CURSOR = Wx::Cursor.new

  BLACK = Wx::Colour.new
  BLUE = Wx::Colour.new
  CYAN = Wx::Colour.new
  GREEN = Wx::Colour.new
  YELLOW = Wx::Colour.new
  LIGHT_GREY = Wx::Colour.new
  RED = Wx::Colour.new
  WHITE = Wx::Colour.new
  YELLOW = Wx::Colour.new

end
