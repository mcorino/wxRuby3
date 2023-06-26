###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class EventFilter < Director

      def setup
        super
        spec.gc_as_temporary # no tracking
      end
    end # class EventFilter

  end # class Director

end # module WXRuby3
