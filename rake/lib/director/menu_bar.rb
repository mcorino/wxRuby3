#--------------------------------------------------------------------
# @file    menu_bar.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

require_relative './window'

module WXRuby3

  class Director

    class MenuBar < Window

      def setup
        spec.no_proxy('wxMenuBar::Refresh',
                'wxMenuBar::FindItem',
                'wxMenuBar::Remove',
                'wxMenuBar::Replace')
        spec.ignore('wxMenuBar::wxMenuBar(size_t,wxMenu *[],const wxString[],long)',
                'wxMenuBar::GetLabelTop',
                'wxMenuBar::SetLabelTop')
        super
      end
    end # class MenuBar

  end # class Director

end # module WXRuby3
