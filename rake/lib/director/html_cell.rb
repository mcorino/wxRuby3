###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class HtmlCell < Director

      def setup
        super
        spec.items << 'wxHtmlLinkInfo' << 'wxHtmlContainerCell' << 'wxHtmlWidgetCell' << 'htmldefs.h'
        spec.make_abstract 'wxHtmlLinkInfo'
        spec.gc_as_temporary 'wxHtmlLinkInfo'
        spec.no_proxy 'wxHtmlCell'
      end
    end # class HtmlCell

  end # class Director

end # module WXRuby3
