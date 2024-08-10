# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class AuiTabArt < Director

      def setup
        super
        spec.items << 'wxAuiDefaultTabArt' << 'wxAuiSimpleTabArt'
        spec.gc_as_object
        spec.disable_proxies
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
        spec.map 'const wxAuiNotebookPageArray&' => 'Array<Wx::AUI::AuiNotebookPage>' do
          map_in temp: 'wxAuiNotebookPageArray tmp', code: <<~__CODE
            if (!NIL_P($input))
            {
              if (TYPE($input) == T_ARRAY)
              {
                for (int i=0; i<RARRAY_LEN($input) ;++i)
                {
                  VALUE rb_el = rb_ary_entry($input, i);
                  void* ptr = 0;
                  int res = SWIG_ConvertPtr(rb_el, &ptr, SWIGTYPE_p_wxAuiNotebookPage,  0);
                  if (!SWIG_IsOK(res) || ptr == 0) 
                  {
                    const char* msg;
                    VALUE rb_msg;
                    if (ptr)
                    {
                      rb_msg = rb_inspect(rb_el);
                      msg = StringValuePtr(rb_msg);
                    }
                    else
                    {
                      msg = "null reference";
                    }
                    rb_raise(rb_eTypeError, "$symname : expected Wx::AUI::AuiNotebookPage for array element for %d but got %s",
                             $argnum-1, msg);
                  }
                  tmp.Add(*reinterpret_cast< wxAuiNotebookPage * >(ptr));
                }
              }
              else
              {
                VALUE msg = rb_inspect($input);
                rb_raise(rb_eArgError, "$symname : expected array for %d but got %s",
                         $argnum-1, StringValuePtr(msg));
              }
            }
            $1 = &tmp;
            __CODE
          map_directorin code: <<~__CODE
            $input = rb_ary_new();
            for (size_t i = 0; i < $1.GetCount(); i++)
            {
              wxAuiNotebookPage& np = $1.Item(i);
              rb_ary_push($input, SWIG_NewPointerObj(SWIG_as_voidptr(&np), SWIGTYPE_p_wxAuiNotebookPage, 0));
            }
            __CODE
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
