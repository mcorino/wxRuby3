# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './window'

module WXRuby3

  class Director

    class FontPickerCtrl < Window

      def setup
        super
        spec.make_concrete 'wxFontPickerCtrl'
        spec.do_not_generate(:variables, :defines, :enums, :functions) # with FontPickerEvent
      end
    end # class FontPickerCtrl

  end # class Director

end # module WXRuby3
