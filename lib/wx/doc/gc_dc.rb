# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx

  class GCDC < Wx::DC

    private :initialize

    # Creates a Wx::GCDC instance for target and
    # passes the instance to the given block to draw on.
    # @overload draw_on()
    #   @yieldparam [Wx::GCDC] dc GCDC instance to draw on
    #   @return [Object] result from block
    # @overload draw_on(dc)
    #   @param [Wx::WindowDC,Wx::MemoryDC] target DC to draw on
    #   @yieldparam [Wx::GCDC] dc GCDC instance to draw on
    #   @return [Object] result from block
    # @overload draw_on(dc)
    #   @param [Wx::PrinterDC] target DC to draw on
    #   @yieldparam [Wx::GCDC] dc GCDC instance to draw on
    #   @return [Object] result from block
    #   @wxrb_require USE_PRINTING_ARCHITECTURE,WXMSW|WXOSX|USE_GTKPRINT
    # @overload draw_on(gc)
    #   Note that the context will continue using the same font, pen and brush as before until #set_font, #set_pen
    #   or #set_brush is explicitly called to change them. This means that the code can use this wxDC-derived object
    #   to work using pens and brushes with alpha component, for example (which normally isn't supported by Wx::DC API),
    #   but it also means that the return values of #get_font, #get_pen and #get_brush won't really correspond to the
    #   actually used objects because they simply can't represent them anyhow. If you wish to avoid such discrepancy,
    #   you need to call the setter methods to bring Wx::DC and Wx::GraphicsContext font, pen and brush in sync with each other.
    #   @param [Wx::GraphicsContext] gc GraphicsContext to draw on
    #   @yieldparam [Wx::GCDC] dc GCDC instance to draw on
    #   @return [Object] result from block
    def self.draw_on(*arg) end
  end

end
