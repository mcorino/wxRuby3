# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './window'

module WXRuby3

  class Director

    class HtmlListBox < Window

      include Typemap::ClientData

      def setup
        spec.items << 'wxSimpleHtmlListBox' << 'wxItemContainer'
        super
        if Config.instance.wx_version_check('3.3.0') > 0
          spec.override_inheritance_chain('wxHtmlListBox', ['wxVListBox', 'wxVScrolledWindow', 'wxPanel', 'wxWindow', 'wxEvtHandler', 'wxObject'])
        else
          spec.override_inheritance_chain('wxHtmlListBox', ['wxVListBox', { 'wxVScrolledWindow' => 'wxHScrolledWindow' }, 'wxPanel', 'wxWindow', 'wxEvtHandler', 'wxObject'])
        end
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
              return {};
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
        # optimize; no need for these virtuals here
        spec.no_proxy 'wxHtmlListBox::OnGetRowHeight',
                      'wxHtmlListBox::OnGetRowsHeightHint'

        # override inheritance chain
        if Config.instance.wx_version_check('3.3.0') > 0
          spec.override_inheritance_chain('wxSimpleHtmlListBox', ['wxHtmlListBox', 'wxVListBox', 'wxVScrolledWindow', 'wxPanel', 'wxWindow', 'wxEvtHandler', 'wxObject'])
        else
          spec.override_inheritance_chain('wxSimpleHtmlListBox', ['wxHtmlListBox', 'wxVListBox', { 'wxVScrolledWindow' => 'wxHScrolledWindow' }, 'wxPanel', 'wxWindow', 'wxEvtHandler', 'wxObject'])
        end
        spec.fold_bases('wxSimpleHtmlListBox' => %w[wxItemContainer])
        # override SWIG's confusion
        spec.make_concrete 'wxSimpleHtmlListBox'
        # not useful overload
        spec.ignore 'wxSimpleHtmlListBox::wxSimpleHtmlListBox(wxWindow *, wxWindowID, const wxPoint &, const wxSize &, int, const wxString[], long, const wxValidator &, const wxString &)'
        # add missing overloads
        spec.extend_interface 'wxSimpleHtmlListBox',
                              'virtual wxString GetString(unsigned int n) const',
                              'virtual void SetString(unsigned int n, const wxString &string)'
        spec.ignore([ 'wxItemContainer::Append(const wxString &, void *)',
                      'wxItemContainer::Append(const std::vector< wxString > &)',
                      'wxItemContainer::Append(const wxArrayString &, void **)',
                      'wxItemContainer::Append(unsigned int, const wxString *)',
                      'wxItemContainer::Append(unsigned int, const wxString *, void **)',
                      'wxItemContainer::Append(unsigned int, const wxString *, wxClientData **)',
                      'wxItemContainer::Insert(const wxString &, unsigned int, void *)',
                      'wxItemContainer::Insert(const std::vector< wxString > &)',
                      'wxItemContainer::Insert(const wxArrayString &, unsigned int, void **)',
                      'wxItemContainer::Insert(unsigned int, const wxString *, unsigned int)',
                      'wxItemContainer::Insert(unsigned int, const wxString *, unsigned int, void **)',
                      'wxItemContainer::Insert(unsigned int, const wxString *, unsigned int, wxClientData **)',
                      'wxItemContainer::Set(const std::vector< wxString > &)',
                      'wxItemContainer::Set(const wxArrayString &, void **)',
                      'wxItemContainer::Set(unsigned int, const wxString *)',
                      'wxItemContainer::Set(unsigned int, const wxString *, void **)',
                      'wxItemContainer::Set(unsigned int, const wxString *, wxClientData **)',
                      'wxItemContainer::GetClientData',
                      'wxItemContainer::SetClientData',
                      'wxItemContainer::HasClientUntypedData',
                      'wxItemContainer::Clear'])
        spec.ignore([ 'wxItemContainer::DetachClientObject',
                      'wxItemContainer::Append(const wxArrayString &, wxClientData **)',
                      'wxItemContainer::Insert(const wxArrayString &, unsigned int, wxClientData **)',
                      'wxItemContainer::Set(const wxArrayString &, wxClientData **)'], ignore_doc: false)
        # optimize; no need for these virtuals here
        spec.no_proxy 'wxSimpleHtmlListBox::OnGetRowHeight',
                      'wxSimpleHtmlListBox::OnGetRowsHeightHint'
        # for doc only
        spec.map 'void** clientData' => 'Array', swig: false do
          map_in code: ''
        end
        # Replace the old Wx definitions of these methods adding
        # proper checks on the data arrays.
        # Also add an item enumerator.
        spec.add_extend_code 'wxSimpleHtmlListBox', <<~__HEREDOC
          VALUE DetachClientObject(unsigned int n)
          {
            VALUE rc = Qnil;
            wxClientData *wxcd = $self->DetachClientObject(n);
            wxRubyClientData *rbcd = wxcd ? dynamic_cast<wxRubyClientData*> (wxcd) : nullptr;
            if (rbcd)
            {
              rc = rbcd->GetData();
              delete rbcd;
            }
            return rc;
          }

          int Append(const wxArrayString &items, VALUE rb_clientData)
          {
            if (TYPE(rb_clientData) != T_ARRAY || 
                  static_cast<unsigned int> (RARRAY_LEN(rb_clientData)) != items.GetCount())
            {
              rb_raise(rb_eArgError, 
                       TYPE(rb_clientData) == T_ARRAY ? 
                          "expected Array for client_data" : 
                          "client_data Array needs to be equal in size to items Array");
            }

            std::unique_ptr<wxClientData*[]> cd_arr = std::make_unique<wxClientData*[]> (RARRAY_LEN(rb_clientData));
            for (int i=0; i<RARRAY_LEN(rb_clientData) ;++i)
            {
              cd_arr[i] = new wxRubyClientData(rb_ary_entry(rb_clientData, i));
            }
            return $self->Append(items, cd_arr.get());
          }

          int Insert(const wxArrayString &items, unsigned int pos, VALUE rb_clientData)
          {
            if (TYPE(rb_clientData) != T_ARRAY || 
                  static_cast<unsigned int> (RARRAY_LEN(rb_clientData)) != items.GetCount())
            {
              rb_raise(rb_eArgError, 
                       TYPE(rb_clientData) == T_ARRAY ? 
                          "expected Array for client_data" : 
                          "client_data Array needs to be equal in size to items Array");
            }

            std::unique_ptr<wxClientData*[]> cd_arr = std::make_unique<wxClientData*[]> (RARRAY_LEN(rb_clientData));
            for (int i=0; i<RARRAY_LEN(rb_clientData) ;++i)
            {
              cd_arr[i] = new wxRubyClientData(rb_ary_entry(rb_clientData, i));
            }
            return $self->Insert(items, pos, cd_arr.get());
          }

          void Set(const wxArrayString &items, VALUE rb_clientData)
          {
            if (TYPE(rb_clientData) != T_ARRAY || 
                  static_cast<unsigned int> (RARRAY_LEN(rb_clientData)) != items.GetCount())
            {
              rb_raise(rb_eArgError, 
                       TYPE(rb_clientData) == T_ARRAY ? 
                          "expected Array for client_data" : 
                          "client_data Array needs to be equal in size to items Array");
            }

            std::unique_ptr<wxClientData*[]> cd_arr = std::make_unique<wxClientData*[]> (RARRAY_LEN(rb_clientData));
            for (int i=0; i<RARRAY_LEN(rb_clientData) ;++i)
            {
              cd_arr[i] = new wxRubyClientData(rb_ary_entry(rb_clientData, i));
            }
            $self->Set(items, cd_arr.get());
          }

          VALUE each_string()
          {
            VALUE rc = Qnil;
            for (unsigned int i=0; i<$self->GetCount() ;++i)
            {
              VALUE rb_s = WXSTR_TO_RSTR($self->GetString(i));
              rc = rb_yield(rb_s);
            }
            return rc;
          }
        __HEREDOC
      end
    end # class HtmlListBox

  end # class Director

end # module WXRuby3
