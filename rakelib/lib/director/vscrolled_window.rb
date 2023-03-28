###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './window'

module WXRuby3

  class Director

    class VScrolledWindow < Window

      def setup
        super
        spec.items << 'wxVarVScrollHelper' << 'wxVarScrollHelperBase'
        spec.override_inheritance_chain('wxVScrolledWindow', %w[wxPanel wxWindow wxEvtHandler wxObject])
        spec.fold_bases('wxVScrolledWindow' => %w[wxVarVScrollHelper wxVarScrollHelperBase])
        spec.make_abstract 'wxVScrolledWindow'
        spec.force_proxy 'wxVScrolledWindow'
        # provide base implementation for OnGetRowHeight
        spec.add_header_code <<~__HEREDOC
          // Custom subclass implementation. 
          class wxRubyVScrolledWindow : public wxVScrolledWindow
          {
          public:
            wxRubyVScrolledWindow() 
              : wxVScrolledWindow () {}
            wxRubyVScrolledWindow(wxWindow *parent, wxWindowID id=wxID_ANY, const wxPoint &pos=wxDefaultPosition, const wxSize &size=wxDefaultSize, long style=0, const wxString &name=wxPanelNameStr)
              : wxVScrolledWindow(parent, id, pos, size, style, name) {}
          protected:
            virtual wxCoord OnGetRowHeight(size_t) const
            {
              rb_raise(rb_eNoMethodError, "Not implemented");
            }
          };
        __HEREDOC
        # make Ruby director and wrappers use custom implementation
        spec.use_class_implementation('wxVScrolledWindow', 'wxRubyVScrolledWindow')
        # ignore pure virtual base methods
        spec.ignore 'wxVarScrollHelperBase::GetNonOrientationTargetSize',
                    'wxVarScrollHelperBase::GetOrientation',
                    'wxVarScrollHelperBase::GetOrientationTargetSize',
                    'wxVarScrollHelperBase::OnGetUnitSize'
        # extend derived interface with base implementation overrides
        spec.extend_interface 'wxVScrolledWindow',
                              'virtual int GetNonOrientationTargetSize() const',
                              'virtual wxOrientation GetOrientation() const',
                              'virtual int GetOrientationTargetSize() const'
        spec.extend_interface 'wxVScrolledWindow',
                              'virtual wxCoord OnGetUnitSize(size_t unit) const',
                              visibility: 'protected'
        spec.suppress_warning(473, 'wxVScrolledWindow::GetTargetWindow')
      end
    end # class Panel

  end # class VScrolledWindow

end # module WXRuby3
