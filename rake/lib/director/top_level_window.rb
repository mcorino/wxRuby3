#--------------------------------------------------------------------
# @file    top_level_window.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

module WXRuby3

  class Director

    class TopLevelWindow < Director

      def setup
        # for all wxTopLevelWindow (derived) classes
        spec.add_swig_code <<~__HEREDOC
          SWIG_WXTOPLEVELWINDOW_NO_USELESS_VIRTUALS(#{spec.module_name});
        __HEREDOC
        spec.no_proxy %w{
          wxTopLevelWindow::IsFullScreen
          wxWindow::GetDropTarget
          wxWindow::GetValidator
        }
        if spec.module_name == 'wxTopLevelWindow'
          # add these to the generated interface to be parsed by SWIG
          # the wxWidgets docs are flawed in this respect that several reimplemented
          # virtual methods are not documented at the reimplementing class as such
          # that would cause them missing from the interface which would cause a problem
          # for a SWIG director redirecting to the Ruby class as the SWIG wrappers
          # redirect explicitly to the implementation at the same class level as the wrapper
          # for upcalls
          spec.extend_interface('wxTopLevelWindow',
                                'virtual bool Destroy() override',
                                'virtual bool IsTopLevel() override',
                                'virtual void SetLayoutDirection(wxLayoutDirection dir) override',
                                'virtual bool Show(bool show = true) override',
                                'virtual void Raise() override',
                                'virtual void Refresh(bool eraseBackground = true, wxRect const *rect = NULL) override')
          spec.add_wrapper_code <<~__HEREDOC
            extern VALUE wxRuby_GetTopLevelWindowClass() {
              return SwigClassWxTopLevelWindow.klass;
            }
            __HEREDOC
          spec.ignore %w{
            wxTopLevelWindow::SaveGeometry
            wxTopLevelWindow::RestoreToGeometry
            wxTopLevelWindow::GeometrySerializer
          }
          spec.set_only_for '__WXUNIVERSAL__', %w{
            wxTopLevelWindow::IsUsingNativeDecorations
            wxTopLevelWindow::UseNativeDecorations
            wxTopLevelWindow::UseNativeDecorationsByDefault
          }
          spec.set_only_for '__WXMSW__', 'wxTopLevelWindow::MSWGetSystemMenu'
          spec.swig_import 'swig/classes/include/wxDefs.h'
        end
        super
      end
    end # class Frame

  end # class Director

end # module WXRuby3
