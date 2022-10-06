#--------------------------------------------------------------------
# @file    sizer_item.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

module WXRuby3

  class Director

    class SizerItem < Director

      def setup
        spec.disable_proxies
        spec.ignore(%w[wxSizerItem::SetSizer wxSizerItem::SetSpacer wxSizerItem::SetWindow])
        super
      end
    end # class SizerItem

  end # class Director

end # module WXRuby3
