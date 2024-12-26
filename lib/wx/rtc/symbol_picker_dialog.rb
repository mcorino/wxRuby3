# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

class Wx::RTC::SymbolPickerDialog

  # special handling for keyword ctor extension here
  # as this class deviates from 'normal' window ctors
  Wx::define_keyword_ctors(Wx::RTC::SymbolPickerDialog) do
    wx_ctor_params :id, :caption => 'Symbols'
    wx_ctor_params :pos, :size => [400,300]
    wx_ctor_params :style => Wx::DEFAULT_DIALOG_STYLE|Wx::RESIZE_BORDER|Wx::CLOSE_BOX
  end

  # now redefine the overridden ctor to account for deviating arglist
  wx_redefine_method :initialize do |symbol, initialFont, normalTextFont, parent = nil, *mixed_args, &block|
    real_args = begin
                  [ symbol, initialFont, normalTextFont, parent ] + self.class.args_as_list(*mixed_args)
                rescue => err
                  msg = "Error initializing #{self.inspect}\n"+
                    " : #{err.message} \n" +
                    "Provided are #{[ symbol, initialFont, normalTextFont, parent ] + mixed_args} \n" +
                    "Correct parameters for #{self.class.name}.new are:\n" +
                    self.class.describe_constructor(
                      ":symbol => (String)\n:initialFont => (String)\n:normalTextFont => (String)\n:parent => (Wx::Window)\n")

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
          ":symbol => (String)\n:initialFont => (String)\n:normalTextFont => (String)\n:parent => (Wx::Window)\n")

      new_err = err.class.new(msg)
      new_err.set_backtrace(caller)
      Kernel.raise new_err
    end
  end

end
