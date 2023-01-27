###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class PGEditor < Director

      def setup
        super
        spec.items.concat %w[wxPGCheckBoxEditor wxPGChoiceEditor wxPGChoiceAndButtonEditor wxPGComboBoxEditor
                             wxPGTextCtrlEditor wxPGSpinCtrlEditor wxPGTextCtrlAndButtonEditor]
        spec.includes << 'wx/propgrid/propgriddefs.h'
        # custom class to work around lack of default ctor of wxPGWindowList
        spec.add_header_code <<~__HEREDOC
          class WXRB_PGWindowList : public wxPGWindowList
          {
          public:
            WXRB_PGWindowList() : wxPGWindowList(0) {}
            WXRB_PGWindowList(wxWindow *primary, wxWindow *secondary=NULL) : wxPGWindowList(primary, secondary) {}
            WXRB_PGWindowList(const wxPGWindowList& other) : wxPGWindowList(other) {}
            WXRB_PGWindowList& operator=(const wxPGWindowList& lst) { this->m_primary = lst.m_primary; this->m_secondary = lst.m_secondary; return *this; }
            operator wxPGWindowList() { return wxPGWindowList(*this); }
          };
          __HEREDOC
        spec.post_processors << :update_pg_window_list
        spec.map 'wxPGWindowList' => 'Wx::Window,Array<Wx::Window,Wx::Window>' do
          map_out code: <<~__CODE
            wxWindow *winsec = $1.GetSecondary();
            if (winsec) 
            {
              $result = rb_ary_new();
              rb_ary_push($result, wxRuby_WrapWxObjectInRuby($1.GetPrimary()));
              rb_ary_push($result, wxRuby_WrapWxObjectInRuby(winsec));
            }
            else
            {
              $result = wxRuby_WrapWxObjectInRuby($1.GetPrimary());
            }
            __CODE
          map_directorout code: <<~__CODE
            if (TYPE($input) == T_ARRAY && RARRAY_LEN($input) >= 1)
            {
              void *ptr;
              int res = SWIG_ConvertPtr(rb_ary_entry($input, 0), &ptr, SWIGTYPE_p_wxWindow, 0 |  0);
              if (!SWIG_IsOK(res)) 
              {
                Swig::DirectorTypeMismatchException::raise(SWIG_ErrorType(SWIG_ArgError(res)), "in primary output value of type 'wxWindow *'");
              }
              $result = wxPGWindowList(static_cast<wxWindow*>(ptr));
              if (RARRAY_LEN($input) > 1)
              {
                res = SWIG_ConvertPtr(rb_ary_entry($input, 1), &ptr, SWIGTYPE_p_wxWindow, 0 |  0);
                if (!SWIG_IsOK(res)) 
                {
                  Swig::DirectorTypeMismatchException::raise(SWIG_ErrorType(SWIG_ArgError(res)), "in secundary output value of type 'wxWindow *'");
                }
                $result.SetSecondary(static_cast<wxWindow*>(ptr));
              }
            }
            __CODE
        end
      end

    end # class PGEditor

  end # class Director

  module SwigRunner
    # wxPGWindowList lacks a default ctor (stupid!) and therefor cannot be used by SWIG
    # for return by value setups.
    # We declared a compatible version in the header which can be used for var decls
    # and here we're going to replace all SWIG generated decls to use the custom class.
    class Processor
      class UpdatePgWindowList < Processor
        def run
          # just replace all occurrences of wxPGWindowList result var decls by WXRB_PGWindowList decls.
          update_source do |line|
            if /\A\s*wxPGWindowList\s+(c_)?result\s*;/ =~ line
              line.sub!('wxPGWindowList', 'WXRB_PGWindowList')
            end
            line
          end
        end
      end
    end
  end

end # module WXRuby3
