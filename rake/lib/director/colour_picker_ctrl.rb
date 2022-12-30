###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './window'

module WXRuby3

  class Director

    class ColourPickerCtrl < Window

      def setup
        super
        spec.items << 'wxPickerBase'
        spec.fold_bases('wxColourPickerCtrl' => 'wxPickerBase')
        spec.do_not_generate(:variables, :defines, :enums, :functions) # with ColourPickerEvent
      end
    end # class ColourPickerCtrl

  end # class Director

end # module WXRuby3
