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
        # this assumes all MenuItem-s created by users will always be added to a menu
        # (which seems acceptable as there is no use for menu items otherwise)
        # if not the C++ item will never be deleted before the process terminates
        # (but this goes for all object marked for GC_NEVER).
        spec.gc_never
        spec.ignore(%w[wxMenuItem::GetLabel wxMenuItem::GetName wxMenuItem::GetText wxMenuItem::SetText wxMenuItem::GetLabelFromText])
        # ignore this as there is no implementation anymore
        spec.ignore 'wxMenuItem::GetAccelFromString'
        spec.set_only_for 'wxUSE_ACCEL', 'wxMenuItem::GetAccel'
        spec.no_proxy 'wxMenuItem::GetAccel'
        spec.ignore 'wxMenuItem::GetBitmap(bool)' # not portable
        if Config.instance.wx_version < '3.2.0'
          spec.set_only_for('__WXMSW__', 'wxMenuItem::SetBitmap(const wxBitmap &,bool)')
        end
        super
      end
    end # class MenuItem

  end # class Director

end # module WXRuby3
