###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './window'

module WXRuby3

  class Director

    class HtmlWindow < Window

      include Typemap::HtmlCell

      def setup
        super
        spec.items << 'wxHtmlFilter' << 'htmlpars.h'
        spec.gc_as_window 'wxHtmlWindow'
        spec.override_inheritance_chain('wxHtmlWindow', %w[wxScrolledWindow wxPanel wxWindow wxEvtHandler wxObject])
        # add members from wxHtmlWindowInterface
        # (we do it like this because we do not want pure virtual declarations which is
        # what we would get if we used fold_bases)
        spec.extend_interface 'wxHtmlWindow',
                              'enum HTMLCursor { HTMLCursor_Default, HTMLCursor_Link, HTMLCursor_Text }',
                              'virtual wxPoint HTMLCoordsToWindow(wxHtmlCell *cell, const wxPoint& pos) const',
                              'virtual wxWindow* GetHTMLWindow()',
                              'virtual wxColour GetHTMLBackgroundColour() const',
                              'virtual void SetHTMLBackgroundColour(const wxColour& clr)',
                              'virtual void SetHTMLBackgroundImage(const wxBitmapBundle& bmpBg)',
                              'virtual void SetHTMLStatusText(const wxString& text)',
                              'virtual wxCursor GetHTMLCursor(HTMLCursor type) const'
        # handled; can be suppressed
        spec.suppress_warning(473, "wxHtmlWindow::GetHTMLWindow")
        # deprecated; use event handler instead
        spec.ignore 'wxHtmlWindow::OnLinkClicked'
        spec.no_proxy 'wxHtmlWindow::SendAutoScrollEvents'
        spec.add_header_code 'typedef wxHtmlWindow::HTMLCursor HTMLCursor;'
        # type mapping for LoadFile, SetFonts and OnOpeningURL
        spec.map 'const wxFileName &filename' => 'String' do
          # Deal with wxFileName
          map_in temp: 'wxFileName tmp', code: <<~__CODE
            tmp = wxFileName(RSTR_TO_WXSTR($input));
            $1 = &tmp;
            __CODE
        end
        spec.map 'const int* sizes' => 'Array(Integer,Integer,Integer,Integer,Integer,Integer,Integer)' do
          # Deal with sizes argument to SetFonts
          map_in code: <<~__CODE
            if ( TYPE($input) != T_ARRAY || RARRAY_LEN($input) != 7 )
              rb_raise(rb_eTypeError, 
                       "The 'font sizes' argument must be an array with 7 integers");
            $1 = new int[7];
            for ( size_t i = 0; i < 7; i++ )
              ($1)[i] = NUM2INT(rb_ary_entry($input, i));
            __CODE
          map_freearg code: 'if ($1) delete[]($1);'
        end
        spec.map 'const wxString &url, wxString *redirect' do
          # deal with OnOpeningURL's "wxString *redirect" argument
          map_directorin code: '$input = WXSTR_TO_RSTR($1);'
        end
        spec.map 'wxHtmlOpeningStatus' => 'true,false,String' do
          map_directorout code: ''
          map_out code: <<~__CODE
            switch ($1)
            {
              case wxHTML_OPEN: $result = Qtrue; break;
              case wxHTML_REDIRECT: $result = WXSTR_TO_RSTR(redir_tmp4); break;
              default: $result = Qfalse; break; // BLOCK
            }
          __CODE
        end
        spec.map 'wxString *redirect' do
          map_directorargout code: <<~__CODE
            if (TYPE(result) == T_STRING)
            {
              *redirect = RSTR_TO_WXSTR(result);
              c_result = wxHTML_REDIRECT;
            }
            else if (result != Qnil && result != Qfalse)
            {
              c_result = wxHTML_OPEN;
            }
            else
            {
              c_result = wxHTML_BLOCK;
            }
            __CODE
          map_in ignore: true, temp: 'wxString redir_tmp', code: '$1 = &redir_tmp;'
        end

        # disown added HtmlFilter-s (pure Ruby override takes care of GC marking)
        spec.disown 'wxHtmlFilter*'
      end
    end # class HtmlWindow

  end # class Director

end # module WXRuby3
