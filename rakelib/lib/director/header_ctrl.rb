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
        spec.no_proxy 'wxHeaderCtrlSimple'
        spec.gc_as_marked 'wxHeaderColumn', 'wxSettableHeaderColumn', 'wxHeaderColumnSimple'
        spec.regard 'wxHeaderCtrl::GetColumn',
                    'wxHeaderCtrl::UpdateColumnVisibility',
                    'wxHeaderCtrl::UpdateColumnsOrder',
                    'wxHeaderCtrl::UpdateColumnWidthToFit',
                    'wxHeaderCtrl::OnColumnCountChanging'
        spec.regard 'wxHeaderCtrlSimple::GetBestFittingWidth'
        spec.extend_interface 'wxHeaderCtrlSimple',
                              'virtual const wxHeaderColumn& GetColumn(unsigned int idx) const',
                              'virtual void UpdateColumnVisibility(unsigned int idx, bool show)',
                              'virtual void UpdateColumnsOrder(const wxArrayInt& order)',
                              visibility: 'protected'
        # handled; can be suppressed
        spec.suppress_warning(473, 'wxHeaderCtrl::GetColumn', 'wxHeaderCtrlSimple::GetColumn')
        # ignore here as already available through HeaderCtrlEvent
        spec.ignore '@.wxHD_ALLOW_REORDER',
                    '@.wxHD_ALLOW_HIDE',
                    '@.wxHD_BITMAP_ON_RIGHT',
                    '@.wxHD_DEFAULT_STYLE'
        # add pure virtual base overrides missing from docs
        spec.extend_interface 'wxSettableHeaderColumn',
                              'wxString GetTitle() const override',
                              'wxBitmap GetBitmap() const override',
                              'int GetWidth() const override',
                              'int GetMinWidth() const override',
                              'wxAlignment GetAlignment() const override',
                              'int GetFlags() const override',
                              'bool IsSortKey() const override',
                              'bool IsSortOrderAscending() const override'
        spec.do_not_generate :typedefs, :variables, :defines, :functions
      end
    end # class HeaderCtrl

  end # class Director

end # module WXRuby3
