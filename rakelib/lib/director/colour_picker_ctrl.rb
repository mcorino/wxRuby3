# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './window'

module WXRuby3

  class Director

    class ColourPickerCtrl < Window

      def setup
        super
        spec.make_concrete 'wxColourPickerCtrl'
        spec.do_not_generate(:variables, :defines, :enums, :functions) # with ColourPickerEvent
      end
    end # class ColourPickerCtrl

  end # class Director

end # module WXRuby3
