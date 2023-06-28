###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class RichTextHeaderFooterData < Director

      def setup
        super
        spec.gc_as_untracked
        spec.disable_proxies # fixed and final data structures
      end
    end # class RichTextHeaderFooterData

  end # class Director

end # module WXRuby3
