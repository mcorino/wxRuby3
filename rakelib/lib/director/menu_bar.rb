# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './window'

module WXRuby3

  class Director

    class MenuBar < Window

      def setup
        spec.no_proxy('wxMenuBar::FindItem',
                'wxMenuBar::Remove',
                'wxMenuBar::Replace')
        spec.ignore('wxMenuBar::wxMenuBar(size_t,wxMenu *[],const wxString[],long)',
                'wxMenuBar::GetLabelTop',
                'wxMenuBar::SetLabelTop',
                'wxMenuBar::Refresh')
        unless Config.instance.wx_version >= '3.3' || Config.instance.wx_abi_version > '3.0.0'
          spec.ignore 'wxMenuBar::OSXGetAppleMenu'
        end
        super
      end
    end # class MenuBar

  end # class Director

end # module WXRuby3
