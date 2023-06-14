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
        spec.add_swig_code '%feature("notabstract") wxColourPickerCtrl;'
        spec.do_not_generate(:variables, :defines, :enums, :functions) # with ColourPickerEvent
      end
    end # class ColourPickerCtrl

  end # class Director

end # module WXRuby3
