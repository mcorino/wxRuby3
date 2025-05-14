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
    # Redefine #add and #insert methods to support positional and named
    # arguments
    SIZER_ADD_PARAMS = [Wx::Parameter[:proportion, 0],
                        Wx::Parameter[:flag, 0],
                        Wx::Parameter[:border, 0],
                        Wx::Parameter[:userData, nil]]

    wx_sizer_add = instance_method :add
    wx_redefine_method :add do |*args, **kwargs|

      if args.last.is_a?(Wx::SizerFlags)  # using 'flags' variant?
        wx_sizer_add.bind(self).call(*args) # no need for keyword scanning
      else
        full_args = []

        full_args << args.shift # get first argument

        unless full_args.first.is_a?(Wx::Window) || full_args.first.is_a?(Wx::Sizer)
          full_args << args.shift # must be spacer variant, get height argument as well
        end

        begin
          args = Wx::args_as_list(SIZER_ADD_PARAMS, *args, **kwargs)
        rescue => err
          err.set_backtrace(caller)
          Kernel.raise err
        end

        # update the full arguments list with the optional arguments
        full_args.concat(args)

        # Call original add with full args
        wx_sizer_add.bind(self).call(*full_args)
      end

    end

    wx_sizer_insert = instance_method :insert
    wx_redefine_method :insert do |index, *args, **kwargs|

      if args.last.is_a?(Wx::SizerFlags)  # using 'flags' variant?
        wx_sizer_insert.bind(self).call(index, *args) # no need for keyword scanning
      else
        full_args = []

        full_args << args.shift # get first argument after index

        unless full_args.first.is_a?(Wx::Window) || full_args.first.is_a?(Wx::Sizer)
          full_args << args.shift # must be spacer variant, get height argument as well
        end

        begin
          args = Wx::args_as_list(SIZER_ADD_PARAMS, *args, **kwargs)
        rescue => err
          err.set_backtrace(caller)
          Kernel.raise err
        end

        # update the full arguments list with the optional arguments
        full_args.concat(args)

        # Call original insert with full args
        wx_sizer_insert.bind(self).call(index, *full_args)
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

    # Redefine #add method to support positional and named
    # arguments
    GBSIZER_ADD_PARAMS = [Wx::Parameter[:span, Wx::DEFAULT_SPAN],
                          Wx::Parameter[:flag, 0],
                          Wx::Parameter[:border, 0],
                          Wx::Parameter[:userData, nil]]

    wx_gbsizer_add = instance_method :add
    wx_redefine_method :add do |*args, **kwargs|

      full_args = []

      full_args << args.shift # get first argument

      unless full_args.first.is_a?(Wx::Window) || full_args.first.is_a?(Wx::Sizer)
        full_args << args.shift # must be spacer variant, get height argument as well
      end

      # get mandatory pos arg
      full_args << args.shift

      begin
        args = Wx::args_as_list(GBSIZER_ADD_PARAMS, *args, **kwargs)
      rescue => err
        err.set_backtrace(caller)
        Kernel.raise err
      end

      # update the full arguments list with the optional arguments
      full_args.concat(args)

      # Call original add with full args
      wx_gbsizer_add.bind(self).call(*full_args)

    end

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

  class GBPosition

    include Comparable

    # make GBPosition usable for parallel assignments like `r, c = pos`
    def to_ary
      [row, col]
    end

    # Compare with another position value
    def <=>(other)
      this_row, this_col = to_ary
      if Wx::GBPosition === other
        that_row, that_col = other.to_ary
      elsif Array === other and other.size == 2
        that_row, that_col = other
      else
        return nil
      end

      if this_row < that_row
        -1
      elsif that_row < this_row
        1
      else
        this_col <=> that_col
      end
    end

    def eql?(other)
      if other.instance_of?(self.class)
        self == other
      else
        false
      end
    end

    def hash
      to_ary.hash
    end

    def dup
      Wx::GBPosition.new(*self.to_ary)
    end

  end

  class GBSpan

    # make GBSpan usable for parallel assignments like `r, c = span`
    def to_ary
      [rowspan, colspan]
    end

    def eql?(other)
      if other.instance_of?(self.class)
        self == other
      else
        false
      end
    end

    def hash
      to_ary.hash
    end

    def dup
      Wx::GBSpan.new(*self.to_ary)
    end

  end

end
