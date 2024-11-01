# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# 
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

# Just a shortcut version for creating a vertical box sizer

class Wx::VBoxSizer < Wx::BoxSizer
  def initialize(&block)
    super(Wx::VERTICAL, &nil)
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

# Just a shortcut version for creating a vertical wrap sizer
class Wx::VWrapSizer < Wx::WrapSizer
  def initialize(flags=Wx::WRAPSIZER_DEFAULT_FLAGS, &block)
    super(Wx::VERTICAL, &nil)
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
