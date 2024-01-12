# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

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
        spec.ignore_unless('USE_ACCEL', 'wxMenuItem::GetAccel')
        spec.no_proxy 'wxMenuItem::GetAccel'
        spec.ignore 'wxMenuItem::GetBitmap(bool)' # not portable
        if Config.instance.wx_version > '3.2.4'
          spec.ignore_unless('WXMSW', 'wxMenuItem::SetBackgroundColour','wxMenuItem::SetFont','wxMenuItem::SetTextColour')
        end
        super
      end
    end # class MenuItem

  end # class Director

end # module WXRuby3
