# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# 
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

class Wx::MenuBar

  alias :wx_initialize :initialize

  def initialize(*args, &block)
    wx_initialize(*args)
    if block
      if block.arity == -1 or block.arity == 0
        self.instance_eval(&block)
      elsif block.arity == 1
        block.call(self)
      else
        Kernel.raise ArgumentError,
                     "Block to initialize should accept a single argument or none"
      end
    end
  end

end
