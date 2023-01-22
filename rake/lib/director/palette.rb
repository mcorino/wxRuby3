###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class Palette < Director

      def setup
        super
        spec.disable_proxies
      end
    end # class Palette

  end # class Director

end # module WXRuby3
