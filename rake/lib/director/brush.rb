###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class Brush < Director

      def setup
        super
        spec.disable_proxies
        spec.do_not_generate :variables
      end
    end # class Brush

  end # class Director

end # module WXRuby3
