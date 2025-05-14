# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# 
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

# Classes for automatically managing layouts

module Wx
  class Sizer
    # Generic method to add items, supporting positional and named
    # arguments
    ADD_ITEM_PARAMS = [Wx::Parameter[:index, -1],
                       Wx::Parameter[:proportion, 0],
                       Wx::Parameter[:flag, 0],
                       Wx::Parameter[:border, 0]]

    def add_item(item, *args, **kwargs)

      begin
        args = Wx::args_as_list(ADD_ITEM_PARAMS, *args, **kwargs)
      rescue => err
        err.set_backtrace(caller)
        Kernel.raise err
      end

      full_args = []

      # extract the width and the height in the case of a spacer
      # defined as an array
      if item.kind_of?(Array)
        Kernel.raise ArgumentError,
                     "Invalid Sizer specification : [width, height] expected" if item.size != 2
        full_args << item[0] << item[1]
      else
        full_args << item
      end

      # update the full arguments list with the optional arguments (except index)
      idx = args.shift
      full_args.concat(args)

      # Call add to append if default position
      if idx == -1
        add(*full_args)
      else
        insert(idx, *full_args)
      end
    end

    # Overload to provide Enumerator without block
    wx_each_child = instance_method :each_child
    wx_redefine_method :each_child do |&block|
      if block
        wx_each_child.bind(self).call(&block)
      else
        ::Enumerator.new { |y| wx_each_child.bind(self).call { |c| y << c } }
      end
    end

  end

  class BoxSizer < Sizer

    wx_initialize = instance_method :initialize
    wx_redefine_method :initialize do |*args, &block|
      wx_initialize.bind(self).call(*args)
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

  class WrapSizer < BoxSizer

    wx_initialize = instance_method :initialize
    wx_redefine_method :initialize do |*args, &block|
      wx_initialize.bind(self).call(*args)
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

  class StaticBoxSizer < BoxSizer

    wx_initialize = instance_method :initialize
    wx_redefine_method :initialize do |*args, &block|
      wx_initialize.bind(self).call(*args)
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

  class StdDialogButtonSizer < BoxSizer

    wx_initialize = instance_method :initialize
    wx_redefine_method :initialize do |*args, &block|
      wx_initialize.bind(self).call(*args)
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

  class GridSizer < Sizer

    wx_initialize = instance_method :initialize
    wx_redefine_method :initialize do |*args, &block|
      wx_initialize.bind(self).call(*args)
      self.instance_eval(&block) if block
    end

  end

  class FlexGridSizer < GridSizer

    wx_initialize = instance_method :initialize
    wx_redefine_method :initialize do |*args, &block|
      wx_initialize.bind(self).call(*args)
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

  class GridBagSizer < FlexGridSizer

    wx_initialize = instance_method :initialize
    wx_redefine_method :initialize do |*args, &block|
      wx_initialize.bind(self).call(*args)
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

end
