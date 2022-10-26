#--------------------------------------------------------------------
# @file    menu_item.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

module WXRuby3

  class Director

    class MenuItem < Director

      def setup
        spec.ignore(%w[wxMenuItem::GetLabel wxMenuItem::GetName wxMenuItem::GetText wxMenuItem::SetText wxMenuItem::GetLabelFromText])
        spec.no_proxy('wxMenuItem::GetAccel')
        if Config.instance.wx_version < '3.2.0'
          spec.set_only_for('__WXMSW__', 'wxMenuItem::SetBitmap(const wxBitmap &,bool)')
        end
        super
      end
    end # class MenuItem

  end # class Director

end # module WXRuby3
