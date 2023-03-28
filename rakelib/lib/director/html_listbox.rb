###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './window'

module WXRuby3

  class Director

    class HtmlListBox < Window

      def setup
        spec.items << 'wxSimpleHtmlListBox'
        super
        spec.override_inheritance_chain('wxHtmlListBox', %w[wxVListBox wxVScrolledWindow wxPanel wxWindow wxEvtHandler wxObject])
        spec.make_abstract 'wxHtmlListBox'
        # provide base implementation for OnGetItem
        spec.add_header_code <<~__HEREDOC
          // Custom subclass implementation. 
          class wxRubyHtmlListBox : public wxHtmlListBox
          {
          public:
            wxRubyHtmlListBox() 
              : wxHtmlListBox () {}
            wxRubyHtmlListBox(wxWindow *parent, wxWindowID id=wxID_ANY, const wxPoint &pos=wxDefaultPosition, const wxSize &size=wxDefaultSize, long style=0, const wxString &name=wxHtmlListBoxNameStr)
              : wxHtmlListBox(parent, id, pos, size, style, name) {}
          protected:
            virtual wxString 	OnGetItem (size_t n) const
            {
              rb_raise(rb_eNoMethodError, "Not implemented");
            }
          };
        __HEREDOC
        # make Ruby director and wrappers use custom implementation
        spec.use_class_implementation('wxHtmlListBox', 'wxRubyHtmlListBox')
        # we do not want wxFileSystem exposed (not worth the trouble)
        spec.ignore 'wxHtmlListBox::GetFileSystem'
        # just add an extension to change the path for resolving relative paths in HTML
        spec.add_extend_code 'wxHtmlListBox', <<~__HEREDOC
          void change_filesystem_path_to(const wxString& location, bool is_dir=false)
          {
            $self->GetFileSystem().ChangePathTo(location, is_dir);
          }
          __HEREDOC
        # override inheritance chain
        spec.override_inheritance_chain('wxSimpleHtmlListBox', %w[wxHtmlListBox wxVListBox wxVScrolledWindow wxPanel wxWindow wxEvtHandler wxObject])
      end
    end # class HtmlListBox

  end # class Director

end # module WXRuby3
