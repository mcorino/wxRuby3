###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './window'

module WXRuby3

  class Director

    class FontPickerCtrl < Window

      def setup
        super
        spec.items << 'wxPickerBase'
        spec.fold_bases('wxFontPickerCtrl' => 'wxPickerBase')
        spec.ignore 'wxPickerBase::CreateBase', 'wxPickerBase::UpdatePickerFromTextCtrl', 'wxPickerBase::UpdateTextCtrlFromPicker'
        spec.do_not_generate(:variables, :defines, :enums, :functions) # with FontPickerEvent
      end
    end # class FontPickerCtrl

  end # class Director

end # module WXRuby3
