# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx
  class DC

    # Provides similar functionality like wxDCBrushChanger setting the given brush as the active
    # brush for the DC for the duration of the block execution restoring the previous brush afterwards.
    # @param [Wx::Brush] brush new brush to use during block execution
    # @return [void]
    # @yieldparam [Wx::DC] dc the DC (self)
    def with_brush(brush) end

    # Provides similar functionality like wxDCPenChanger setting the given pen as the active
    # pen for the DC for the duration of the block execution restoring the previous pen afterwards.
    # @param [Wx::Pen] pen new pen to use during block execution
    # @return [void]
    # @yieldparam [Wx::DC] dc the DC (self)
    def with_pen(pen) end

    # Provides similar functionality like wxDCFontChanger setting the given font as the active
    # font for the DC for the duration of the block execution restoring the previous font afterwards.
    # @param [Wx::Font] font new font to use during block execution
    # @return [void]
    # @yieldparam [Wx::DC] dc the DC (self)
    def with_font(font) end

    # Provides similar functionality like wxDCTextColourChanger setting the given colour as the active
    # text foreground colour for the DC for the duration of the block execution restoring the previous colour afterwards.
    # @param [Wx::Colour] clr new colour to use during block execution
    # @return [void]
    # @yieldparam [Wx::DC] dc the DC (self)
    def with_text_foreground(clr) end
    alias :with_text_fg :with_text_foreground

    # Provides similar functionality like wxDCTextBgColourChanger setting the given colour as the active
    # text background colour for the DC for the duration of the block execution restoring the previous colour afterwards.
    # @param [Wx::Colour] clr new colour to use during block execution
    # @return [void]
    # @yieldparam [Wx::DC] dc the DC (self)
    def with_text_background(clr) end
    alias :with_text_bg :with_text_background

    # Provides similar functionality like wxDCTextBgModeChanger setting the given mode as the active
    # background mode for the DC for the duration of the block execution restoring the previous mode afterwards.
    # @param [Integer] mode new mode to use during block execution
    # @return [void]
    # @yieldparam [Wx::DC] dc the DC (self)
    def with_background_mode(mode) end
    alias :with_bg_mode :with_background_mode

  end

end
