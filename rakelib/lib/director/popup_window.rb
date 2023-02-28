###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './window'

module WXRuby3

  class Director

    class PopupWindow < Window

      def setup
        spec.items << 'wxPopupTransientWindow'
        super
      end

    end # class PopupWindow

  end # class Director

end # module WXRuby3
