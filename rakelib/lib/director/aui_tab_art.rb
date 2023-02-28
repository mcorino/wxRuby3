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
        # for DrawTab and GetTabSize
        spec.map_apply('int * OUTPUT' => 'int * x_extent')
        # for DrawButton and DrawTab
        spec.map 'wxRect *' => 'Wx::Rect' do
          map_in ignore: true, temp: 'wxRect tmpRect', code: '$1 = &tmpRect;'
          map_argout code: <<~__CODE
            if (TYPE($result) == T_ARRAY)
            {
              $result = SWIG_Ruby_AppendOutput($result, SWIG_NewPointerObj($1, SWIGTYPE_p_wxRect, 0));
            }
            else
            {
              $result = SWIG_NewPointerObj($1, SWIGTYPE_p_wxRect, 0);
            }
            __CODE
          map_directorargout code: <<~__CODE
            void* ptr = 0;
            int res$argnum = SWIG_ConvertPtr($result, &ptr, SWIGTYPE_p_wxRect,  0 );
            if (!SWIG_IsOK(res$argnum)) {
              Swig::DirectorTypeMismatchException::raise(rb_eTypeError, "Expected Wx::Rect result");
            }
            *$1 = *reinterpret_cast<wxRect*> (ptr);
            __CODE
        end
        spec.suppress_warning(473,
                              'wxAuiTabArt::Clone',
                              'wxAuiDefaultTabArt::Clone',
                              'wxAuiSimpleTabArt::Clone')
        spec.do_not_generate(:variables, :defines, :enums, :functions)
      end
    end # class AuiTabArt

  end # class Director

end # module WXRuby3
