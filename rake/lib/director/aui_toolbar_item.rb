###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class AuiToolBarItem < Director

      def setup
        super
        spec.gc_as_object
      end
    end # class AuiToolBarItem

  end # class Director

end # module WXRuby3
