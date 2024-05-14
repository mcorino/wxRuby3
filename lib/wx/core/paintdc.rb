# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# 
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

module Wx

  class PaintDC

    def self.draw_on(win, &block)
      win.paint(&block) if block
    end

  end

  AutoBufferedPaintDC = PaintDC.has_native_double_buffer ? Wx::PaintDC : Wx::BufferedPaintDC

end
