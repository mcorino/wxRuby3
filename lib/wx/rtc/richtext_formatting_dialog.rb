# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

class Wx::RTC::RichTextFormattingDialog

  class << self

    wx_set_formatting_dialog_factory = instance_method :set_formatting_dialog_factory
    define_method :set_formatting_dialog_factory do |factory|
      wx_set_formatting_dialog_factory.bind(self).call(factory)
      @factory = factory # cache here to prevent GC collection
    end

  end

  # special handling for keyword ctor extension here
  # as this class deviates from 'normal' window ctors
  Wx::define_keyword_ctors(Wx::RTC::RichTextFormattingDialog) do
    wx_ctor_params :title => 'Formatting'
    wx_ctor_params :id, :pos, :size, :style => Wx::DEFAULT_DIALOG_STYLE
  end

  # now redefine the overridden ctor to account for deviating arglist
  def initialize(flags, parent = nil, *mixed_args, &block)
    real_args = begin
                  [ flags, parent ] + self.class.args_as_list(*mixed_args)
                rescue => err
                  msg = "Error initializing #{self.inspect}\n"+
                    " : #{err.message} \n" +
                    "Provided are #{[ flags, parent ] + mixed_args} \n" +
                    "Correct parameters for #{self.class.name}.new are:\n" +
                    self.class.describe_constructor(
                      ":flags => (Integer)\n:parent => (Wx::Window)\n")

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
          ":flags => (Integer)\n:parent => (Wx::Window)\n")

      new_err = err.class.new(msg)
      new_err.set_backtrace(caller)
      Kernel.raise new_err
    end
  end

end
