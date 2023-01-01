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
        # wxWidgets provides a whole class for writing custom styles for the
        # tabs in AuiNotebooks. Rather than add the whole API and having to provide
        # customized GC handling, only provide access to allow switching between the two
        # styles that come with wxWidgets.
        spec.ignore(%w[wxAuiNotebook::GetArtProvider wxAuiNotebook::SetArtProvider])
        spec.add_extend_code 'wxAuiNotebook', <<~__HEREDOC
          void use_glossy_art()
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
          wxAuiNotebook::AddPage
          wxAuiNotebook::DeleteAllPages
          wxAuiNotebook::DeletePage
          wxAuiNotebook::InsertPage
          wxAuiNotebook::RemovePage
          wxAuiNotebook::GetPageCount
          wxAuiNotebook::SetFont
          ]
      end
    end # class AuiNotebook

  end # class Director

end # module WXRuby3
