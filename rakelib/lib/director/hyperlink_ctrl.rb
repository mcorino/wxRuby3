###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './window'

module WXRuby3

  class Director

    class HyperlinkCtrl < Window

      def setup
        super
        if Config.instance.wx_version <= '3.3.0'
          # XML docs (< 3.3) incorrectly declare these pure virtual
          spec.ignore 'wxHyperlinkCtrl::GetVisited', 'wxHyperlinkCtrl::SetVisited', ignore_doc: false
          # replace by correct declarations
          spec.extend_interface 'wxHyperlinkCtrl',
                                'virtual bool wxHyperlinkCtrl::GetVisited() const',
                                'virtual void wxHyperlinkCtrl::SetVisited(bool visited = true)'
        end
      end
    end # class HyperlinkCtrl

  end # class Director

end # module WXRuby3
