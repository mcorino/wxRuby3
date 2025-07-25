# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './book_ctrls'

module WXRuby3

  class Director

    class AuiNotebook < BookCtrls

      include Typemap::AuiTabCtrl

      def setup
        super
        spec.override_inheritance_chain(spec.module_name, %w[wxBookCtrlBase wxControl wxWindow wxEvtHandler wxObject])
        if spec.module_name == 'wxAuiNotebook'
          spec.items << 'wxAuiNotebookPage'
          spec.regard %w[wxAuiNotebookPage::window
                         wxAuiNotebookPage::caption
                         wxAuiNotebookPage::tooltip
                         wxAuiNotebookPage::bitmap
                         wxAuiNotebookPage::active]
          if Config.instance.wx_version_check('3.3.0') >= 0
            spec.items << 'wxAuiNotebookPosition'
            spec.regard 'wxAuiNotebookPosition::tabCtrl',
                        'wxAuiNotebookPosition::tabIdx'
            spec.make_readonly 'wxAuiNotebookPosition::tabCtrl',
                               'wxAuiNotebookPosition::tabIdx'

            spec.map 'std::vector<wxAuiTabCtrl*>' => 'Array<Wx::AUI::AuiTabCtrl>' do
              map_out code: <<~__CODE
                $result = rb_ary_new();
                std::vector<wxAuiTabCtrl*>* tabctrls = (std::vector<wxAuiTabCtrl*>*)&$1;
                for (wxAuiTabCtrl* tabctrl : *tabctrls)
                {
                  VALUE r_tabctrl = _wxRuby_Wrap_wxAuiTabCtrl(tabctrl);
                  rb_ary_push($result, r_tabctrl);
                }
                __CODE
            end
          end
          # reset type mapping done in BookCtrls as the non-const arg is used for query-ing here (FindTab)
          # (wxWidgets should have made this a const arg)
          spec.map_apply 'SWIGTYPE *' => 'wxWindow* page'
          spec.do_not_generate(:variables, :defines, :enums, :functions) # with AuiNotebookEvent
          spec.disown 'wxAuiTabArt * art' # C++ side takes ownership
          # Any set AuiTabArt ruby object must be protected from GC once set,
          # even if it is no longer referenced anywhere else.
          spec.add_header_code <<~__HEREDOC
            extern void GC_mark_wxAuiNotebook(void *ptr)
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
          # add some convenience methods
          spec.add_extend_code 'wxAuiNotebook', <<~__HEREDOC
          void use_default_art()
          { $self->SetArtProvider(new wxAuiDefaultTabArt); }
        
          void use_simple_art()
          { $self->SetArtProvider(new wxAuiSimpleTabArt); }
          __HEREDOC
          # replace FindTab (easier than type mapping)
          spec.ignore('wxAuiNotebook::FindTab')
          spec.add_extend_code 'wxAuiNotebook', <<~__HEREDOC
            VALUE FindTab(wxWindow *page)
            {
              wxAuiTabCtrl *ctrl = 0;
              int idx = -1;
              VALUE rc = Qnil;
              if ($self->FindTab(page, &ctrl, &idx))
              {
                rc = rb_ary_new();
                rb_ary_push(rc, _wxRuby_Wrap_wxAuiTabCtrl(ctrl));
                rb_ary_push(rc, INT2NUM(idx));
              }
              return rc;
            }
            __HEREDOC
        else
          spec.add_header_code <<~__HEREDOC
            // implemented in AuiNotebook.cpp
            extern void GC_mark_wxAuiNotebook(void *ptr);
            __HEREDOC
        end
        spec.add_swig_code '%markfunc wxAuiNotebook "GC_mark_wxAuiNotebook";'
      end
    end # class AuiNotebook

  end # class Director

end # module WXRuby3
