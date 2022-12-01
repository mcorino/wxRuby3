#--------------------------------------------------------------------
# @file    html_cell.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

module WXRuby3

  class Director

    class HtmlCell < Director

      def setup
        super
        spec.items << 'wxHtmlLinkInfo' << 'wxHtmlContainerCell' << 'wxHtmlWidgetCell'
        spec.no_proxy 'wxHtmlCell'
      end
    end # class HtmlCell

  end # class Director

end # module WXRuby3
