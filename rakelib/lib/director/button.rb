###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './window'

module WXRuby3

  class Director

    class Button < Window

      def setup
        spec.no_proxy %w[wxButton::SetDefault]
        super
      end
    end # class Button

  end # class Director

end # module WXRuby3
