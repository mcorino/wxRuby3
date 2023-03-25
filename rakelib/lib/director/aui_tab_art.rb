###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class AuiTabArt < Director

      def setup
        super
        spec.items << 'wxAuiDefaultTabArt' << 'wxAuiSimpleTabArt'
        spec.gc_as_object
        # missing from interface documentation
        spec.extend_interface('wxAuiTabArt',
                              'virtual ~wxAuiTabArt ()',
                              'virtual void DrawBorder(wxDC& dc,wxWindow* wnd,const wxRect& rect) = 0',
                              'virtual int ShowDropDown(wxWindow* wnd,const wxAuiNotebookPageArray& items,int activeIdx) = 0',
                              'virtual int GetBorderWidth(wxWindow* wnd) = 0',
                              'virtual int GetAdditionalBorderSpace(wxWindow* wnd) = 0')
        # ignore documented method (not it's docs)
        spec.ignore 'wxAuiTabArt::DrawTab', ignore_doc: false
        # and re-add with consistently named argument
        spec.extend_interface 'wxAuiTabArt',
                              'virtual void DrawTab(wxDC &dc, wxWindow *wnd, wxAuiNotebookPage const &page, wxRect const &rect, int close_button_state, wxRect *out_tab_rect, wxRect *out_button_rect, int *xExtent) = 0'
        # for DrawTab (cannot simply apply 'int *OUTPUT' as that does not work well with a void method)
        spec.map 'int *xExtent' => 'Integer' do
          map_in ignore: true, temp: 'int tmp', code: '$1 = &tmp;'
          map_argout code: '$result = INT2NUM(tmp$argnum);'
          map_directorargout code: 'if (!NIL_P(result)) *xExtent = NUM2INT(result);'
        end
        # for GetTabSize
        spec.map_apply('int * OUTPUT' => 'int *x_extent')

        spec.suppress_warning(473,
                              'wxAuiTabArt::Clone',
                              'wxAuiDefaultTabArt::Clone',
                              'wxAuiSimpleTabArt::Clone')
        spec.do_not_generate(:variables, :defines, :enums, :functions)
      end
    end # class AuiTabArt

  end # class Director

end # module WXRuby3
