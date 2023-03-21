###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class SystemOptions < Director

      def setup
        super
        spec.gc_never
        spec.make_abstract 'wxSystemOptions'
        spec.disable_proxies
      end
    end # class SystemOptions

  end # class Director

end # module WXRuby3
