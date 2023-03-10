###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class Region < Director

      def setup
        super
        spec.require_app 'wxRegion'
        spec.disable_proxies
        spec.ignore 'wxNullRegion' # does not exist in code
      end
    end # class Region

  end # class Director

end # module WXRuby3
