# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './window'

module WXRuby3

  class Director

    class BookCtrls < Window

      def setup
        super
        # Protect panels etc added as Toolbook pages from being GC'd by Ruby;
        # avoids double-free segfaults on exit on GTK
        spec.map_apply 'SWIGTYPE *DISOWN' => 'wxWindow* page'
        # but not for const args (query methods)
        spec.map_apply 'SWIGTYPE *' => 'const wxWindow* page'
        # argout for HitTest
        spec.map_apply 'long *OUTPUT' => 'long *flags'

        case spec.module_name
        when 'wxBookCtrlBase'
          spec.make_abstract 'wxBookCtrlBase'
          spec.items.replace %w[wxBookCtrlBase bookctrl.h]
          # add fully implemented noop base class for director
          spec.add_header_code <<~__HEREDOC
            class WXRubyBookCtrlBase : public wxBookCtrlBase
            {
            public:
              WXRubyBookCtrlBase () : wxBookCtrlBase() {}
              WXRubyBookCtrlBase(wxWindow *parent,
                                 wxWindowID winid,
                                 const wxPoint& pos = wxDefaultPosition,
                                 const wxSize& size = wxDefaultSize,
                                 long style = 0,
                                 const wxString& name = wxEmptyString)
                : wxBookCtrlBase(parent, winid, pos, size, style, name) 
              {}
              virtual bool SetPageText(size_t, const wxString&) { return false; }
              virtual wxString GetPageText(size_t) const { return wxString(); }

              virtual int GetPageImage(size_t) const { return -1; }
              virtual bool SetPageImage(size_t, int) { return false; }

              virtual bool InsertPage(size_t,
                                      wxWindow *,
                                      const wxString&,
                                      bool = false,
                                      int = NO_IMAGE) { return false; }
          
              virtual int SetSelection(size_t) { return -1; }
              virtual int ChangeSelection(size_t) { return -1; }

            protected:
              virtual wxWindow *DoRemovePage(size_t) { return NULL; } 
            };
            __HEREDOC
          spec.use_class_implementation 'wxBookCtrlBase', 'WXRubyBookCtrlBase'
          spec.ignore 'wxBookCtrl' # useless define in bookctrl.h doc
          spec.override_inheritance_chain('wxBookCtrlBase', %w[wxControl wxWindow wxEvtHandler wxObject])
          #spec.no_proxy('wxBookCtrlBase')
          # mixin WithImages
          spec.include_mixin 'wxBookCtrlBase', 'Wx::WithImages'
        when 'wxNotebook'
          spec.ignore("wxNotebook::OnSelChange")
          # this reimplemented window base method need to be properly wrapped but
          # is missing from the XML docs
          spec.extend_interface('wxNotebook', 'virtual void OnInternalIdle()')
          spec.override_inheritance_chain(spec.module_name, %w[wxBookCtrlBase wxControl wxWindow wxEvtHandler wxObject])
        when 'wxToolbook', 'wxListbook', 'wxChoicebook', 'wxSimplebook'
          setup_book_ctrl_class(spec.module_name)
          spec.force_proxy(spec.module_name)
          if spec.module_name == 'wxToolbook'
            spec.map 'wxToolBarBase *' => 'Wx::ToolBar', swig: false do
              map_out code: ''
            end
            spec.ignore 'wxToolbook::GetToolBar', ignore_doc: false
            spec.extend_interface 'wxToolbook', 'wxToolBar* GetToolBar() const'
          end
        when 'wxTreebook'
          setup_book_ctrl_class(spec.module_name)
          spec.force_proxy(spec.module_name)
          # add public API missing from docs (essential for better control of tree control)
          spec.extend_interface 'wxTreebook', 'wxTreeCtrl* GetTreeCtrl() const'
        end
      end
      
      def setup_book_ctrl_class(clsnm)
        spec.override_inheritance_chain(clsnm, %w[wxBookCtrlBase wxControl wxWindow wxEvtHandler wxObject])
        # add implemented overloads missing from docs
        spec.extend_interface clsnm,
                              'virtual int GetPageImage(size_t nPage) const',
                              'virtual bool SetPageImage(size_t page, int image)',
                              'virtual wxString GetPageText(size_t nPage) const',
                              'virtual bool SetPageText(size_t page, const wxString &text)',
                              'virtual int SetSelection(size_t page)',
                              'virtual int ChangeSelection(size_t page)'
        unless spec.module_name == 'wxTreebook'
          spec.extend_interface clsnm,
                                'virtual int GetSelection() const',
                                'virtual bool InsertPage(size_t index, wxWindow *page, const wxString &text, bool select=false, int imageId=NO_IMAGE)'
        end
      end
    end # class Object

  end # class Director

end # module WXRuby3
