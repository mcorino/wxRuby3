# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

class Wx::RTC::RichTextStyleOrganiserDialog

  # special handling for keyword ctor extension here
  # as this class deviates from 'normal' window ctors
  Wx::define_keyword_ctors(Wx::RTC::RichTextStyleOrganiserDialog) do
    wx_ctor_params :id, :caption => 'Style Organiser'
    wx_ctor_params :pos, :size, :style => Wx::DEFAULT_DIALOG_STYLE|Wx::RESIZE_BORDER|Wx::SYSTEM_MENU|Wx::CLOSE_BOX
  end

  # now redefine the overridden ctor to account for deviating arglist
  wx_redefine_method :initialize do |flags, sheet, ctrl, parent = nil, *mixed_args, &block|
    real_args = begin
                  [ flags, sheet, ctrl, parent ] + self.class.args_as_list(*mixed_args)
                rescue => err
                  msg = "Error initializing #{self.inspect}\n"+
                    " : #{err.message} \n" +
                    "Provided are #{[ flags, sheet, ctrl, parent ] + mixed_args} \n" +
                    "Correct parameters for #{self.class.name}.new are:\n" +
                    self.class.describe_constructor(
                      ":flags => (Integer)\n:sheet => (Wx::RTC::RichTextStyleSheet)\n:ctrl => (Wx::RTC::RichTextCtrl)\n:parent => (Wx::Window)\n")

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
          ":flags => (Integer)\n:sheet => (Wx::RTC::RichTextStyleSheet)\n:ctrl => (Wx::RTC::RichTextCtrl)\n:parent => (Wx::Window)\n")

      new_err = err.class.new(msg)
      new_err.set_backtrace(caller)
      Kernel.raise new_err
    end
  end

end
