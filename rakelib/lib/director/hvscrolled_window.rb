# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './window'

module WXRuby3

  class Director

    class HVScrolledWindow < Window

      def setup
        super
        spec.items << 'wxVarScrollHelperBase' << 'wxVarHVScrollHelper' << 'wxVarVScrollHelper' << 'wxVScrolledWindow' << 'wxVarHScrollHelper' << 'wxHScrolledWindow'
        spec.override_inheritance_chain('wxVScrolledWindow', %w[wxPanel wxWindow wxEvtHandler wxObject])
        spec.fold_bases('wxVScrolledWindow' => %w[wxVarVScrollHelper wxVarScrollHelperBase])
        spec.make_abstract 'wxVScrolledWindow'
        spec.force_proxy 'wxVScrolledWindow'
        spec.override_inheritance_chain('wxHScrolledWindow', %w[wxPanel wxWindow wxEvtHandler wxObject])
        spec.fold_bases('wxHScrolledWindow' => %w[wxVarHScrollHelper wxVarScrollHelperBase])
        spec.make_abstract 'wxHScrolledWindow'
        spec.force_proxy 'wxHScrolledWindow'
        spec.override_inheritance_chain('wxHVScrolledWindow', %w[wxPanel wxWindow wxEvtHandler wxObject])
        spec.fold_bases('wxHVScrolledWindow' => %w[wxVarHVScrollHelper wxVarHScrollHelper wxVarVScrollHelper wxVarScrollHelperBase])
        spec.make_abstract 'wxHVScrolledWindow'
        spec.force_proxy 'wxHVScrolledWindow'
        # provide base implementations for pure virtuals
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
              return {};
            }
          };

          // Custom subclass implementation. 
          class wxRubyHScrolledWindow : public wxHScrolledWindow
          {
          public:
            wxRubyHScrolledWindow() 
              : wxHScrolledWindow () {}
            wxRubyHScrolledWindow(wxWindow *parent, wxWindowID id=wxID_ANY, const wxPoint &pos=wxDefaultPosition, const wxSize &size=wxDefaultSize, long style=0, const wxString &name=wxPanelNameStr)
              : wxHScrolledWindow(parent, id, pos, size, style, name) {}
          protected:
            virtual wxCoord OnGetColumnWidth(size_t) const
            {
              return {};
            }
          };

          // Custom subclass implementation. 
          class wxRubyHVScrolledWindow : public wxHVScrolledWindow
          {
          public:
            wxRubyHVScrolledWindow() 
              : wxHVScrolledWindow () {}
            wxRubyHVScrolledWindow(wxWindow *parent, wxWindowID id=wxID_ANY, const wxPoint &pos=wxDefaultPosition, const wxSize &size=wxDefaultSize, long style=0, const wxString &name=wxPanelNameStr)
              : wxHVScrolledWindow(parent, id, pos, size, style, name) {}
          protected:
            virtual wxCoord OnGetRowHeight(size_t) const
            {
              return {};
            }
            virtual wxCoord OnGetColumnWidth(size_t) const
            {
              return {};
            }
          };
        __HEREDOC
        # make Ruby director and wrappers use custom implementation
        spec.use_class_implementation('wxVScrolledWindow', 'wxRubyVScrolledWindow')
        spec.use_class_implementation('wxHScrolledWindow', 'wxRubyHScrolledWindow')
        spec.use_class_implementation('wxHVScrolledWindow', 'wxRubyHVScrolledWindow')
        # ignore internal implementation methods
        spec.ignore 'wxVarScrollHelperBase::GetNonOrientationTargetSize',
                    'wxVarScrollHelperBase::GetOrientation',
                    'wxVarScrollHelperBase::GetOrientationTargetSize',
                    'wxVarScrollHelperBase::OnGetUnitSize',
                    'wxVarScrollHelperBase::CalcScrolledPosition',
                    'wxVarScrollHelperBase::CalcUnscrolledPosition',
                    'wxVarScrollHelperBase::GetTargetWindow',
                    'wxVarScrollHelperBase::SetTargetWindow',
                    'wxVarScrollHelperBase::UpdateScrollbar',
                    'wxVarScrollHelperBase::RefreshAll'
      end
    end # class HVScrolledWindow

  end # class Director

end # module WXRuby3
