###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class HtmlCell < Director

      def setup
        super
        spec.items << 'wxHtmlLinkInfo' << 'wxHtmlContainerCell' << 'htmldefs.h'
        # the classes here are internal and for reference only
        # should never be derived from or instantiated in (Ruby) user code
        spec.disable_proxies
        spec.make_abstract 'wxHtmlCell'
        spec.make_abstract 'wxHtmlLinkInfo'
        spec.make_abstract 'wxHtmlContainerCell'
        spec.gc_as_temporary 'wxHtmlLinkInfo' # no tracking
      end
    end # class HtmlCell

  end # class Director

end # module WXRuby3
