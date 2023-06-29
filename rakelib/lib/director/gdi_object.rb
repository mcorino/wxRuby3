###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class GDIObject < Director

      def setup
        spec.make_abstract('wxGDIObject')
        spec.no_proxy('wxGDIObject')
        spec.gc_as_untracked 'wxGDIObject'
        super
      end
    end # class GDIObject

  end # class Director

end # module WXRuby3
