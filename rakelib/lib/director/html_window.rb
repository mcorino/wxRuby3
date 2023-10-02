# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './window'

module WXRuby3

  class Director

    class HtmlWindow < Window

      include Typemap::HtmlCell
      include Typemap::ConfigBase

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
        spec.map 'HTMLCursor' => 'Integer' do
          map_in code: '$1 = static_cast<HTMLCursor> (NUM2INT($input));'
          map_directorin code: '$input = INT2NUM((int)$1);'
        end
        # Deal with sizes argument to SetFonts
        spec.map 'const int *sizes' => 'Array(Integer,Integer,Integer,Integer,Integer,Integer,Integer), nil' do
          map_in temp: 'int tmp[7]', code: <<~__CODE
            if (NIL_P($input))
            {
              $1 = NULL;
            }
            else if (TYPE($input) == T_ARRAY && RARRAY_LEN($input) == 7)
            {
              tmp[0] = NUM2INT(rb_ary_entry($input, 0));
              tmp[1] = NUM2INT(rb_ary_entry($input, 1));
              tmp[2] = NUM2INT(rb_ary_entry($input, 2));
              tmp[3] = NUM2INT(rb_ary_entry($input, 3));
              tmp[4] = NUM2INT(rb_ary_entry($input, 4));
              tmp[5] = NUM2INT(rb_ary_entry($input, 5));
              tmp[6] = NUM2INT(rb_ary_entry($input, 6));
              $1 = &tmp[0];
            }
            else
            {
              VALUE msg = rb_inspect($input);
              rb_raise(rb_eArgError, "Expected nil or array of 7 integers for %d but got %s",
                       $argnum-1, StringValuePtr(msg));
            }
          __CODE
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
