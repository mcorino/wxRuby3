###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './window'

module WXRuby3

  class Director

    class AuiTabCtrl < Window

      def setup
        # first let Director::Window do it's stuff
        super
        # now replace items because wxAuiTabCtrl is actually not documented (!!!)
        spec.items.replace %w[wxAuiTabContainerButton]
        spec.gc_as_temporary 'wxAuiTabContainerButton'
        spec.no_proxy %w[wxAuiTabCtrl wxAuiTabContainerButton]
        spec.swig_import %w[swig/classes/include/wxObject.h swig/classes/include/wxEvtHandler.h swig/classes/include/wxWindow.h swig/classes/include/wxControl.h]
        # cannot use #add_extend_code because we do not have an actual parsed XML item
        spec.add_swig_code <<~__CODE
          GC_MANAGE_AS_WINDOW(wxAuiTabCtrl);

          %extend wxAuiTabCtrl {
            VALUE TabHitTest(int x, int y)
            {
              wxWindow* hit = 0;
              if (self->TabHitTest(x, y, &hit))
              {
                return wxRuby_WrapWxObjectInRuby(hit);
              }
              else
              {
                return Qnil;
              }
            }
            VALUE ButtonHitTest(int x, int y)
            {
              wxAuiTabContainerButton* hit = 0;
              if (self->ButtonHitTest(x, y, &hit))
              {
                wxAuiTabContainerButton* rc_hit = new wxAuiTabContainerButton(*hit);
                // return owned copy 
                return SWIG_NewPointerObj(SWIG_as_voidptr(rc_hit), SWIGTYPE_p_wxAuiTabContainerButton, 1);
              }
              else
              {
                return Qnil;
              }
            }
          };
          __CODE
        # add the missing interface spec (with the wxAuiTabContainer interface folded in minus replaced/shadowed methods)
        # also add wxAuiTabContainerButton manually here
        spec.add_interface_code <<~__HEREDOC
          class wxAuiTabContainerButton
          {
          public:
              int id;
              int curState;
              int location;
              wxBitmapBundle bitmap;
              wxBitmapBundle disBitmap;
              wxRect rect;
          };

          class wxAuiTabCtrl : public wxControl
          {
          public:
              wxAuiTabCtrl(wxWindow* parent, wxWindowID id = wxID_ANY, const wxPoint& pos = wxDefaultPosition, const wxSize& size = wxDefaultSize, long style = 0);
              ~wxAuiTabCtrl();
          
              bool IsDragging() const;
              void SetRect(const wxRect& rect);

              void SetArtProvider(wxAuiTabArt* art);
              wxAuiTabArt* GetArtProvider() const;
          
              void SetFlags(unsigned int flags);
              unsigned int GetFlags() const;
          
              bool AddPage(wxWindow* page, const wxAuiNotebookPage& info);
              bool InsertPage(wxWindow* page, const wxAuiNotebookPage& info, size_t idx);
              bool MovePage(wxWindow* page, size_t newIdx);
              bool RemovePage(wxWindow* page);
              bool SetActivePage(wxWindow* page);
              bool SetActivePage(size_t page);
              void SetNoneActive();
              int GetActivePage() const;
              wxWindow* GetWindowFromIdx(size_t idx) const;
              int GetIdxFromWindow(const wxWindow* page) const;
              size_t GetPageCount() const;
              wxAuiNotebookPage& GetPage(size_t idx);
              const wxAuiNotebookPage& GetPage(size_t idx) const;
              wxAuiNotebookPageArray& GetPages();
              void SetNormalFont(const wxFont& normalFont);
              void SetSelectedFont(const wxFont& selectedFont);
              void SetMeasuringFont(const wxFont& measuringFont);
              void SetColour(const wxColour& colour);
              void SetActiveColour(const wxColour& colour);
              void DoShowHide();
          
              void RemoveButton(int id);
              void AddButton(int id, int location, const wxBitmapBundle& normalBitmap = wxBitmapBundle(), const wxBitmapBundle& disabledBitmap = wxBitmapBundle());
          
              size_t GetTabOffset() const;
              void SetTabOffset(size_t offset);
          
              bool IsTabVisible(int tabPage, int tabOffset, wxDC* dc, wxWindow* wnd);
          
              void MakeTabVisible(int tabPage, wxWindow* win);
          };
          __HEREDOC
      end
    end # class AuiTabCtrl

  end # class Director

end # module WXRuby3
