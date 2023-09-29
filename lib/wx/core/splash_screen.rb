# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# 
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

class Wx::SplashScreen

  # special handling for keyword ctor extension here
  # as this class deviates from 'normal' window ctors
  Wx::define_keyword_ctors(Wx::SplashScreen) do
    wx_ctor_params :id, :pos, :size, :style => Wx::SIMPLE_BORDER|Wx::FRAME_NO_TASKBAR|Wx::STAY_ON_TOP
  end

  # now redefine the overridden ctor to account for deviating arglist
  def initialize(bitmap, splashstyle, milliseconds, parent = nil, *mixed_args, &block)
    # no zero-args ctor for use with XRC!

    real_args = begin
                  [ bitmap, splashstyle, milliseconds, parent ] + self.class.args_as_list(*mixed_args)
                rescue => err
                  msg = "Error initializing #{self.inspect}\n"+
                    " : #{err.message} \n" +
                    "Provided are #{[ bitmap, splashstyle, milliseconds, parent ] + mixed_args} \n" +
                    "Correct parameters for #{self.class.name}.new are:\n" +
                    self.class.describe_constructor(
                      ":bitmap => (Wx::Bitmap)\n:splashstyle => (Integer)\n:milliseconds => (Integer)\n:parent => (Wx::Window)\n")

                  new_err = err.class.new(msg)
                  new_err.set_backtrace(caller)
                  Kernel.raise new_err
                end
    begin
      pre_wx_kwctor_init(*real_args)
    rescue => err
      msg = "Error initializing #{self.inspect}\n"+
        " : #{err.message} \n" +
        "Provided are #{real_args} \n" +
        "Correct parameters for #{self.class.name}.new are:\n" +
        self.class.describe_constructor(
          ":bitmap => (Wx::Bitmap)\n:splashstyle => (Integer)\n:milliseconds => (Integer)\n:parent => (Wx::Window)\n")

      new_err = err.class.new(msg)
      new_err.set_backtrace(caller)
      Kernel.raise new_err
    end

    # If a block was given, pass the newly created Window instance
    # into it; use block
    if block
      if block.arity == -1 or block.arity == 0
        self.instance_eval(&block)
      elsif block.arity == 1
        block.call(self)
      else
        Kernel.raise ArgumentError,
                     "Block to initialize accepts zero or one arg"
      end
    end
  end

end
