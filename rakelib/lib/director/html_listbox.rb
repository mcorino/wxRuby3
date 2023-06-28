###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './window'

module WXRuby3

  class Director

    class HtmlListBox < Window

      def setup
        spec.items << 'wxSimpleHtmlListBox' << 'wxItemContainer'
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
        # make sure protected methods are included
        spec.regard 'wxHtmlListBox::OnGetItem',
                    'wxHtmlListBox::OnGetItemMarkup',
                    'wxHtmlListBox::GetSelectedTextColour',
                    'wxHtmlListBox::GetSelectedTextBgColour',
                    'wxHtmlListBox::OnLinkClicked'
        # add missing protected overloads
        spec.extend_interface 'wxHtmlListBox',
                              'virtual void OnDrawItem(wxDC &dc, const wxRect &rect, size_t n) const',
                              'virtual wxCoord OnMeasureItem(size_t n) const',
                              'virtual void OnDrawBackground(wxDC &dc, const wxRect &rect, size_t n) const',
                              'virtual void OnDrawSeparator(wxDC& dc, wxRect& rect, size_t n) const',
                              visibility: 'protected'

        # override inheritance chain
        spec.override_inheritance_chain('wxSimpleHtmlListBox', %w[wxHtmlListBox wxVListBox wxVScrolledWindow wxPanel wxWindow wxEvtHandler wxObject])
        spec.fold_bases('wxSimpleHtmlListBox' => %w[wxItemContainer])
        # override SWIG's confusion
        spec.make_concrete 'wxSimpleHtmlListBox'
        # not useful overload
        spec.ignore 'wxSimpleHtmlListBox::wxSimpleHtmlListBox(wxWindow *, wxWindowID, const wxPoint &, const wxSize &, int, const wxString[], long, const wxValidator &, const wxString &)'
        # add missing overloads
        spec.extend_interface 'wxSimpleHtmlListBox',
                              'virtual wxString GetString(unsigned int n) const',
                              'virtual void SetString(unsigned int n, const wxString &string)'
        spec.ignore([ 'wxItemContainer::Append(const wxString &, wxClientData *)',
                      'wxItemContainer::Append(const std::vector< wxString > &)',
                      'wxItemContainer::Append(const wxArrayString &, wxClientData **)',
                      'wxItemContainer::Append(unsigned int, const wxString *)',
                      'wxItemContainer::Append(unsigned int, const wxString *, void **)',
                      'wxItemContainer::Append(unsigned int, const wxString *, wxClientData **)',
                      'wxItemContainer::Insert(const wxString &, unsigned int, wxClientData *)',
                      'wxItemContainer::Insert(const std::vector< wxString > &)',
                      'wxItemContainer::Insert(const wxArrayString &, unsigned int, wxClientData **)',
                      'wxItemContainer::Insert(unsigned int, const wxString *, unsigned int)',
                      'wxItemContainer::Insert(unsigned int, const wxString *, unsigned int, void **)',
                      'wxItemContainer::Insert(unsigned int, const wxString *, unsigned int, wxClientData **)',
                      'wxItemContainer::Set(const std::vector< wxString > &)',
                      'wxItemContainer::Set(const wxArrayString &, wxClientData **)',
                      'wxItemContainer::Set(unsigned int, const wxString *)',
                      'wxItemContainer::Set(unsigned int, const wxString *, void **)',
                      'wxItemContainer::Set(unsigned int, const wxString *, wxClientData **)',
                      'wxItemContainer::DetachClientObject',
                      'wxItemContainer::HasClientObjectData',
                      'wxItemContainer::GetClientObject',
                      'wxItemContainer::SetClientObject',
                      'wxItemContainer::HasClientUntypedData',
                      'wxItemContainer::Clear'])
        spec.ignore([ 'wxItemContainer::Append(const wxArrayString &, void **)',
                      'wxItemContainer::Insert(const wxArrayString &, unsigned int, void **)',
                      'wxItemContainer::Set(const wxArrayString &, void **)'], ignore_doc: false)
        # for doc only
        spec.map 'void** clientData' => 'Array', swig: false do
          map_in code: ''
        end
        spec.ignore(%w[wxItemContainer::GetClientData wxItemContainer::SetClientData], ignore_doc: false) # keep docs
        # Replace the old Wx definition of this method (which segfaults)
        # Only need the setter as we cache data in Ruby and the getter
        # therefor can be pure Ruby
        spec.add_extend_code('wxSimpleHtmlListBox', <<~__HEREDOC
            VALUE set_client_data(int n, VALUE item_data) {
              self->SetClientData(n, (void *)item_data);
              return item_data;
            }
        __HEREDOC
        )
      end
    end # class HtmlListBox

  end # class Director

end # module WXRuby3
