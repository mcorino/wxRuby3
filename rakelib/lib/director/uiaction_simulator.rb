###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class UIActionSimulator < Director

      def setup
        super
        spec.gc_as_untracked # no tracking
      end
    end # class UIActionSimulator

  end # class Director

end # module WXRuby3
