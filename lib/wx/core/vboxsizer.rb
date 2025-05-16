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

class Wx::VStaticBoxSizer < Wx::StaticBoxSizer
  def initialize(box_or_window, *rest, &block)
    if box_or_window.is_a?(Wx::StaticBox)
      raise ArgumentError, "Unexpected argument(s) #{rest}" unless rest.empty?
      super(box_or_window, Wx::VERTICAL, &nil)
    else
      raise ArgumentError, "Unexpected argument(s) #{rest}" unless rest.size <= 1
      super(Wx::VERTICAL, box_or_window, *rest, &block)
    end
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
