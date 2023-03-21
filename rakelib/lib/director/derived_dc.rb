###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class DerivedDC < Director

      def setup
        super
        spec.disable_proxies
        # all ctors of derived DC require a running App
        spec.require_app spec.module_name
      end
    end # class DerivedDC

  end # class Director

end # module WXRuby3
