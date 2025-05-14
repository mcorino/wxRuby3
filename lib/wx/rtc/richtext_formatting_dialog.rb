# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

module Wx::RTC
  class RichTextFormattingDialog

    class << self

      wx_set_formatting_dialog_factory = instance_method :set_formatting_dialog_factory
      wx_redefine_method :set_formatting_dialog_factory do |factory|
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
    wx_redefine_method :initialize do |flags = nil, parent = nil, *args, **kwargs, &block|
      # allow zero-args ctor for use with XRC
      if flags.nil?
        pre_wx_kwctor_init
        return
      end

      real_args = begin
                    [ flags, parent ] + self.class.args_as_list(*args, **kwargs)
                  rescue => err
                    msg = "Error initializing #{self.inspect}\n"+
                      " : #{err.message} \n" +
                      "Provided are #{[ flags, parent ] + args + [kwargs]} \n" +
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

  # undocumented flag constants
  RICHTEXT_FORMAT_MARGINS = 0x0040
  RICHTEXT_FORMAT_SIZE = 0x0080
  RICHTEXT_FORMAT_BORDERS = 0x0100
  RICHTEXT_FORMAT_BACKGROUND = 0x0200

  class RichTextObjectPropertiesDialog < RichTextFormattingDialog

    ID_RICHTEXTOBJECTPROPERTIESDIALOG = 10650

    def initialize(*args)
      super()
      create(*args)
    end

    def create(obj, parent, id = ID_RICHTEXTOBJECTPROPERTIESDIALOG, caption = 'Object Properties', pos = Wx::DEFAULT_POSITION, size = [400,300], style = Wx::DEFAULT_DIALOG_STYLE|Wx::TAB_TRAVERSAL)
      set_object(obj)
      set_extra_style(Wx::DIALOG_EX_CONTEXTHELP)
      flags = Wx::RTC::RICHTEXT_FORMAT_SIZE|Wx::RTC::RICHTEXT_FORMAT_MARGINS|Wx::RTC::RICHTEXT_FORMAT_BORDERS|Wx::RTC::RICHTEXT_FORMAT_BACKGROUND
      super(flags, parent, caption, id, pos, size, style)
    end

  end
end
