###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './book_ctrls'

module WXRuby3

  class Director

    class AuiNotebook < BookCtrls

      def setup
        super
        setup_book_ctrl_class(spec.module_name)
        spec.do_not_generate(:variables, :defines, :enums, :functions) # with AuiNotebookEvent
        # Any set AuiTabArt ruby object must be protected from GC once set,
        # even if it is no longer referenced anywhere else.
        spec.add_header_code <<~__HEREDOC
          static void GC_mark_wxAuiNotebook(void *ptr)
          {
            if ( GC_IsWindowDeleted(ptr) )
            {
              return;
            }
            // Do standard marking routines as for all wxWindows
            GC_mark_wxWindow(ptr);

            wxAuiNotebook* nbk = (wxAuiNotebook*)ptr;
            wxAuiTabArt* art_prov = nbk->GetArtProvider();
            VALUE rb_art_prov = SWIG_RubyInstanceFor( (void *)art_prov );
            rb_gc_mark( rb_art_prov );
          }
        __HEREDOC
        spec.add_swig_code '%markfunc wxAuiNotebook "GC_mark_wxAuiNotebook";'
        # add some convenience methods
        spec.add_extend_code 'wxAuiNotebook', <<~__HEREDOC
          void use_default_art()
          { $self->SetArtProvider(new wxAuiDefaultTabArt); }
        
          void use_simple_art()
          { $self->SetArtProvider(new wxAuiSimpleTabArt); }
          __HEREDOC
        # ignore these overridden base methods which are not proxied in base
        spec.ignore %w[
          wxAuiNotebook::GetPageImage
          wxAuiNotebook::GetPageText
          wxAuiNotebook::GetSelection
          wxAuiNotebook::SetPageImage
          wxAuiNotebook::SetPageText
          wxAuiNotebook::SetSelection
          wxAuiNotebook::ChangeSelection
          wxAuiNotebook::DeleteAllPages
          wxAuiNotebook::DeletePage
          wxAuiNotebook::RemovePage
          wxAuiNotebook::GetPageCount
          wxAuiNotebook::SetFont
          ]
        spec.ignore('wxAuiNotebook::AddPage(wxWindow*,const wxString&, bool, int')
        spec.ignore('wxAuiNotebook::InsertPage(size_t, wxWindow*,const wxString&, bool, int')
      end
    end # class AuiNotebook

  end # class Director

end # module WXRuby3
