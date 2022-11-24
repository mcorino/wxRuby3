#--------------------------------------------------------------------
# @file    top_level_window.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

require_relative './window'

module WXRuby3

  class Director

    class TopLevelWindow < Window

      def setup
        super
        # for all wxTopLevelWindow (derived) classes
        spec.no_proxy("#{spec.module_name}::ClearBackground",
                      "#{spec.module_name}::Enable",
                      "#{spec.module_name}::EnableCloseButton",
                      "#{spec.module_name}::EndModal",
                      "#{spec.module_name}::GetHelpTextAtPoint",
                      "#{spec.module_name}::GetMaxSize",
                      "#{spec.module_name}::GetMinSize",
                      "#{spec.module_name}::GetTitle",
                      "#{spec.module_name}::Iconize",
                      "#{spec.module_name}::IsActive",
                      "#{spec.module_name}::IsFullScreen",
                      "#{spec.module_name}::IsMaximzed",
                      "#{spec.module_name}::IsModal",
                      "#{spec.module_name}::IsTopLevel",
                      "#{spec.module_name}::IsVisible",
                      "#{spec.module_name}::Maximize",
                      "#{spec.module_name}::Navigate",
                      "#{spec.module_name}::Refresh",
                      "#{spec.module_name}::Reparent",
                      "#{spec.module_name}::RequestUserAttention",
                      "#{spec.module_name}::Restore",
                      "#{spec.module_name}::SetIcon",
                      "#{spec.module_name}::SetIcons",
                      #"#{spec.module_name}::SetMaxSize",
                      #"#{spec.module_name}::SetMinSize",
                      "#{spec.module_name}::SetShape",
                      "#{spec.module_name}::SetSize",
                      "#{spec.module_name}::SetSize",
                      #"#{spec.module_name}::SetSizeHints",
                      #"#{spec.module_name}::SetSizeHints",
                      "#{spec.module_name}::SetTitle",
                      #"#{spec.module_name}::SetTransparent",
                      #"#{spec.module_name}::Show",
                      "#{spec.module_name}::ShowFullScreen",
                      "#{spec.module_name}::ShowModal",
                      "#{spec.module_name}::Update",
                      "#{spec.module_name}::UpdateWindow",
                      "#{spec.module_name}::Validate")

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
      end
    end # class Frame

  end # class Director

end # module WXRuby3
