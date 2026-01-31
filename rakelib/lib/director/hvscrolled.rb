# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './window'

module WXRuby3

  class Director

    class HVScrolled < Window

      def setup
        super
        case spec.module_name
        when 'wxHScrolledWindow'
          spec.items.replace %w[wxVarScrollHelperBase wxVarVScrollHelper wxVarHVScrollHelper wxVarHScrollHelper wxHScrolledWindow wxHVScrolledWindow wxPosition]
          spec.override_inheritance_chain('wxHScrolledWindow', %w[wxPanel wxWindow wxEvtHandler wxObject])
          spec.fold_bases('wxHScrolledWindow' => %w[wxVarHScrollHelper wxVarScrollHelperBase])
          spec.make_abstract 'wxHScrolledWindow'
          # spec.force_proxy 'wxHScrolledWindow'
          spec.override_inheritance_chain('wxHVScrolledWindow', %w[wxPanel wxWindow wxEvtHandler wxObject])
          spec.fold_bases('wxHVScrolledWindow' => %w[wxVarHVScrollHelper wxVarHScrollHelper wxVarVScrollHelper wxVarScrollHelperBase])
          spec.make_abstract 'wxHVScrolledWindow'
          # spec.force_proxy 'wxHVScrolledWindow'
          # # provide base implementations for pure virtuals
          # spec.add_header_code <<~__HEREDOC
          #   // Custom subclass implementation.
          #   class wxRubyHScrolledWindow : public wxHScrolledWindow
          #   {
          #   public:
          #     wxRubyHScrolledWindow()
          #       : wxHScrolledWindow () {}
          #     wxRubyHScrolledWindow(wxWindow *parent, wxWindowID id=wxID_ANY, const wxPoint &pos=wxDefaultPosition, const wxSize &size=wxDefaultSize, long style=0, const wxString &name=wxPanelNameStr)
          #       : wxHScrolledWindow(parent, id, pos, size, style, name) {}
          #   protected:
          #     virtual wxCoord OnGetColumnWidth(size_t) const
          #     {
          #       return {};
          #     }
          #   };
          #
          #   // Custom subclass implementation.
          #   class wxRubyHVScrolledWindow : public wxHVScrolledWindow
          #   {
          #   public:
          #     wxRubyHVScrolledWindow()
          #       : wxHVScrolledWindow () {}
          #     wxRubyHVScrolledWindow(wxWindow *parent, wxWindowID id=wxID_ANY, const wxPoint &pos=wxDefaultPosition, const wxSize &size=wxDefaultSize, long style=0, const wxString &name=wxPanelNameStr)
          #       : wxHVScrolledWindow(parent, id, pos, size, style, name) {}
          #   protected:
          #     virtual wxCoord OnGetRowHeight(size_t) const
          #     {
          #       return {};
          #     }
          #     virtual wxCoord OnGetColumnWidth(size_t) const
          #     {
          #       return {};
          #     }
          #   };
          #   __HEREDOC
          # # make Ruby director and wrappers use custom implementation
          # spec.use_class_implementation('wxHScrolledWindow', 'wxRubyHScrolledWindow')
          # spec.use_class_implementation('wxHVScrolledWindow', 'wxRubyHVScrolledWindow')
          # regard protected methods
          spec.regard 'wxVarVScrollHelper::OnGetRowHeight',
                      'wxVarVScrollHelper::OnGetRowsHeightHint'
          spec.regard 'wxVarHScrollHelper::OnGetColumnWidth',
                      'wxVarHScrollHelper::OnGetColumnsWidthHint'
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
          spec.map 'const wxPosition&' => 'Array(Integer, Integer), Wx::Position' do
            add_header_code '#include <memory>'
            map_in temp: 'std::unique_ptr<$1_basetype> tmp', code: <<~__CODE
            if ( TYPE($input) == T_DATA )
            {
              void* argp$argnum;
              SWIG_ConvertPtr($input, &argp$argnum, $1_descriptor, 0);
              $1 = reinterpret_cast< $1_basetype * >(argp$argnum);
            }
            else if ( TYPE($input) == T_ARRAY )
            {
              $1 = new $1_basetype( NUM2INT( rb_ary_entry($input, 0) ),
                                   NUM2INT( rb_ary_entry($input, 1) ) );
              tmp.reset($1); // auto destruct when method scope ends 
            }
            else
            {
              rb_raise(rb_eTypeError, "Wrong type for $1_basetype parameter");
            }
            __CODE
            map_typecheck precedence: 'POINTER', code: <<~__CODE
            void *vptr = 0;
            $1 = 0;
            if (TYPE($input) == T_ARRAY && RARRAY_LEN($input) == 2)
              $1 = 1;
            else if (TYPE($input) == T_DATA && SWIG_CheckState (SWIG_ConvertPtr ($input, &vptr, $1_descriptor, 0)))
              $1 = 1;
            __CODE
          end
          if Config.instance.wx_version_check('3.3.0') <= 0
            spec.items << 'wxVScrolledWindow'
            spec.override_inheritance_chain('wxVScrolledWindow', %w[wxPanel wxWindow wxEvtHandler wxObject])
            spec.fold_bases('wxVScrolledWindow' => %w[wxVarVScrollHelper wxVarScrollHelperBase])
            spec.make_abstract 'wxVScrolledWindow'
            spec.force_proxy 'wxVScrolledWindow'
            # # provide base implementations for pure virtuals
            # spec.add_header_code <<~__HEREDOC
            #   // Custom subclass implementation.
            #   class wxRubyVScrolledWindow : public wxVScrolledWindow
            #   {
            #   public:
            #     wxRubyVScrolledWindow()
            #       : wxVScrolledWindow () {}
            #     wxRubyVScrolledWindow(wxWindow *parent, wxWindowID id=wxID_ANY, const wxPoint &pos=wxDefaultPosition, const wxSize &size=wxDefaultSize, long style=0, const wxString &name=wxPanelNameStr)
            #       : wxVScrolledWindow(parent, id, pos, size, style, name) {}
            #   protected:
            #     virtual wxCoord OnGetRowHeight(size_t) const
            #     {
            #       return {};
            #     }
            #   };
            #   __HEREDOC
            # # make Ruby director and wrappers use custom implementation
            # spec.use_class_implementation('wxVScrolledWindow', 'wxRubyVScrolledWindow')
          end
          spec.do_not_generate(:typedefs)
        when 'wxVScrolledWindow'
          if Config.instance.wx_version_check('3.3.0') > 0
            spec.items.replace %w[wxVScrolled wxVarScrollHelperBase wxVarVScrollHelper]
            spec.gc_as_window
            spec.use_template_as_class('wxVScrolled', 'wxVScrolledWindow')
            spec.override_inheritance_chain('wxVScrolled', %w[wxPanel wxWindow wxEvtHandler wxObject])
            spec.fold_bases('wxVScrolled' => %w[wxVarVScrollHelper wxVarScrollHelperBase])
            spec.make_abstract 'wxVScrolledWindow'
            # spec.force_proxy 'wxVScrolled'
            spec.swig_import %w[
            swig/classes/include/wxObject.h
            swig/classes/include/wxEvtHandler.h
            swig/classes/include/wxWindow.h
            swig/classes/include/wxPanel.h
            swig/classes/include/wxHScrolledWindow.h
            ]
            # # provide base implementations for pure virtuals
            # spec.add_header_code <<~__HEREDOC
            #   // Custom subclass implementation.
            #   class wxRubyVScrolledWindow : public wxVScrolledWindow
            #   {
            #   public:
            #     wxRubyVScrolledWindow()
            #       : wxVScrolledWindow () {}
            #     wxRubyVScrolledWindow(wxWindow *parent, wxWindowID id=wxID_ANY, const wxPoint &pos=wxDefaultPosition, const wxSize &size=wxDefaultSize, long style=0, const wxString &name=wxPanelNameStr)
            #       : wxVScrolledWindow(parent, id, pos, size, style, name) {}
            #   protected:
            #     virtual wxCoord OnGetRowHeight(size_t) const
            #     {
            #       return {};
            #     }
            #   };
            #   __HEREDOC
            # # make Ruby director and wrappers use custom implementation
            # spec.use_class_implementation('wxVScrolled', 'wxRubyVScrolledWindow')
            # regard protected methods
            spec.regard 'wxVarVScrollHelper::OnGetRowHeight',
                        'wxVarVScrollHelper::OnGetRowsHeightHint'
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
            spec.do_not_generate(:typedefs, :functions, :defines, :variables)
          else
            spec.items.clear
          end
        when 'wxVScrolledCanvas'
          if Config.instance.wx_version_check('3.3.0') > 0
            spec.items.replace %w[wxVScrolled wxVarScrollHelperBase wxVarVScrollHelper]
            spec.gc_as_window
            spec.use_template_as_class('wxVScrolled', 'wxVScrolledCanvas')
            spec.override_inheritance_chain('wxVScrolled', %w[wxPanel wxWindow wxEvtHandler wxObject])
            spec.fold_bases('wxVScrolled' => %w[wxVarVScrollHelper wxVarScrollHelperBase])
            spec.make_abstract 'wxVScrolledCanvas'
            # spec.force_proxy 'wxVScrolled'
            spec.swig_import %w[
            swig/classes/include/wxObject.h
            swig/classes/include/wxEvtHandler.h
            swig/classes/include/wxWindow.h
            swig/classes/include/wxPanel.h
            swig/classes/include/wxHScrolledWindow.h
            ]
            # # provide base implementations for pure virtuals
            # spec.add_header_code <<~__HEREDOC
            #   // Custom subclass implementation.
            #   class wxRubyVScrolledCanvas : public wxVScrolledCanvas
            #   {
            #   public:
            #     wxRubyVScrolledCanvas()
            #       : wxVScrolledCanvas () {}
            #     wxRubyVScrolledCanvas(wxWindow *parent, wxWindowID id=wxID_ANY, const wxPoint &pos=wxDefaultPosition, const wxSize &size=wxDefaultSize, long style=0, const wxString &name=wxPanelNameStr)
            #       : wxVScrolledCanvas(parent, id, pos, size, style, name) {}
            #   protected:
            #     virtual wxCoord OnGetRowHeight(size_t) const
            #     {
            #       return {};
            #     }
            #   };
            #   __HEREDOC
            # # make Ruby director and wrappers use custom implementation
            # spec.use_class_implementation('wxVScrolled', 'wxRubyVScrolledCanvas')
            # regard protected methods
            spec.regard 'wxVarVScrollHelper::OnGetRowHeight',
                        'wxVarVScrollHelper::OnGetRowsHeightHint'
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
            spec.do_not_generate(:typedefs, :functions, :defines, :variables)
          else
            spec.items.clear
          end
        end
      end
    end # class HVScrolledWindow

  end # class Director

end # module WXRuby3
