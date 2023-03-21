###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class GridTableMessage < Director

      def setup
        super
        spec.gc_as_temporary
      end
    end # class GridTableMessage

  end # class Director

end # module WXRuby3
