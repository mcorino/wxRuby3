###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
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
