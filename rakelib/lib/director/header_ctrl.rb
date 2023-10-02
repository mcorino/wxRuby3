# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './window'

module WXRuby3

  class Director

    class HeaderCtrl < Window

      def setup
        super
        spec.items << 'wxHeaderColumn' << 'wxHeaderCtrlSimple' << 'wxSettableHeaderColumn' << 'wxHeaderColumnSimple'
        spec.regard 'wxHeaderCtrl::GetColumn',
                    'wxHeaderCtrl::UpdateColumnVisibility',
                    'wxHeaderCtrl::UpdateColumnsOrder',
                    'wxHeaderCtrl::UpdateColumnWidthToFit',
                    'wxHeaderCtrl::OnColumnCountChanging'
        spec.regard 'wxHeaderCtrlSimple::GetBestFittingWidth'
        spec.extend_interface 'wxHeaderCtrlSimple',
                              'virtual const wxHeaderColumn& GetColumn(unsigned int idx) const',
                              visibility: 'protected'
        # handled; can be suppressed
        spec.suppress_warning(473, 'wxHeaderCtrl::GetColumn', 'wxHeaderCtrlSimple::GetColumn')
      end
    end # class HeaderCtrl

  end # class Director

end # module WXRuby3
