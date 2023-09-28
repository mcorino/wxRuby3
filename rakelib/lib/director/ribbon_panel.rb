# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './window'

module WXRuby3

  class Director

    class RibbonPanel < Window

      def setup
        super
        spec.items << 'wx/ribbon/panel.h'
      end
    end # class RibbonPanel

  end # class Director

end # module WXRuby3
