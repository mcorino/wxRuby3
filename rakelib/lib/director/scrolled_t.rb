# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './window'

module WXRuby3

  class Director

    class ScrolledT < Window

      def setup
        super
        spec.items.replace %w[wxScrolled]
        spec.gc_as_window
        case spec.module_name
        when 'wxScrolledWindow'
          spec.use_template_as_class('wxScrolled', 'wxScrolledWindow')
          spec.override_inheritance_chain('wxScrolled', %w[wxPanel wxWindow wxEvtHandler wxObject])
          spec.extend_interface('wxScrolled', 'virtual ~wxScrolledWindow();')
          spec.include 'wx/panel.h'
          spec.swig_import %w[
            swig/classes/include/wxObject.h
            swig/classes/include/wxEvtHandler.h
            swig/classes/include/wxWindow.h
            swig/classes/include/wxPanel.h
            ]
          spec.no_proxy 'wxScrolledWindow::SendAutoScrollEvents'
          spec.do_not_generate(:typedefs, :functions)
        when 'wxScrolledCanvas'
          spec.use_template_as_class('wxScrolled', 'wxScrolledCanvas')
          spec.override_inheritance_chain('wxScrolled', %w[wxWindow wxEvtHandler wxObject])
          spec.extend_interface('wxScrolled', 'virtual ~wxScrolledCanvas();')
          spec.include 'wx/window.h'
          spec.swig_import %w[
            swig/classes/include/wxObject.h
            swig/classes/include/wxEvtHandler.h
            swig/classes/include/wxWindow.h
            ]
          spec.no_proxy 'wxScrolledCanvas::SendAutoScrollEvents'
          spec.do_not_generate(:typedefs, :functions, :enums) # enums are generated with wxScrolledWindow
        when 'wxScrolledControl'
          spec.use_template_as_class('wxScrolled', 'wxScrolledControl')
          spec.override_inheritance_chain('wxScrolled', %w[wxControl wxWindow wxEvtHandler wxObject])
          spec.extend_interface('wxScrolled', 'virtual ~wxScrolledControl();')
          spec.add_header_code 'typedef wxScrolled<wxControl> wxScrolledControl;'
          spec.include 'wx/control.h'
          spec.swig_import %w[
            swig/classes/include/wxObject.h
            swig/classes/include/wxEvtHandler.h
            swig/classes/include/wxWindow.h
            swig/classes/include/wxControl.h
            ]
          spec.no_proxy 'wxScrolledControl::SendAutoScrollEvents'
          spec.do_not_generate(:typedefs, :functions, :enums) # enums are generated with wxScrolledWindow
        end
        spec.ignore 'wxScrolled::OnDraw'
        spec.ignore 'wxScrolled::GetViewStart(int *,int *)'
        spec.map_apply 'int * OUTPUT' => 'int *'
      end
    end # class ScrolledT

  end # class Director

end # module WXRuby3
