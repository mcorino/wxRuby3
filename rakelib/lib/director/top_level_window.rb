###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './window'

module WXRuby3

  class Director

    class TopLevelWindow < Window

      def setup
        super
        # for all wxTopLevelWindow (derived) classes
        spec.items.each do |itm|
          spec.no_proxy("#{itm}::ClearBackground",
                        "#{itm}::Enable",
                        "#{itm}::EnableCloseButton",
                        "#{itm}::EndModal",
                        "#{itm}::GetHelpTextAtPoint",
                        "#{itm}::GetMaxSize",
                        "#{itm}::GetMinSize",
                        "#{itm}::GetTitle",
                        "#{itm}::Iconize",
                        "#{itm}::IsActive",
                        "#{itm}::IsFullScreen",
                        "#{itm}::IsMaximzed",
                        "#{itm}::IsAlwaysMaximzed",
                        "#{itm}::IsModal",
                        #"#{itm}::IsTopLevel",
                        "#{itm}::IsVisible",
                        "#{itm}::Maximize",
                        "#{itm}::Navigate",
                        "#{itm}::Refresh",
                        "#{itm}::Reparent",
                        "#{itm}::RequestUserAttention",
                        "#{itm}::Restore",
                        "#{itm}::SetIcon",
                        "#{itm}::SetIcons",
                        #"#{itm}::SetMaxSize",
                        #"#{itm}::SetMinSize",
                        "#{itm}::SetShape",
                        "#{itm}::SetSize",
                        "#{itm}::SetSize",
                        #"#{itm}::SetSizeHints",
                        #"#{itm}::SetSizeHints",
                        "#{itm}::SetTitle",
                        #"#{itm}::SetTransparent",
                        #"#{itm}::Show",
                        "#{itm}::ShowFullScreen",
                        "#{itm}::ShowModal",
                        "#{itm}::Update",
                        "#{itm}::UpdateWindow",
                        "#{itm}::Validate")
        end

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
                                #'virtual bool IsTopLevel() override',
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
          unless Config.instance.features_set?('__WXUNIVERSAL__')
            spec.ignore %w{
            wxTopLevelWindow::IsUsingNativeDecorations
            wxTopLevelWindow::UseNativeDecorations
            wxTopLevelWindow::UseNativeDecorationsByDefault
            }
          end
          spec.set_only_for '__WXMSW__',
                            'wxTopLevelWindow::MSWGetSystemMenu'
          spec.ignore('wxTopLevelWindow::MSWGetSystemMenu') unless Config.instance.features_set?('__WXMSW__')
          spec.set_only_for '__WXOSX__',
                            'wxTopLevelWindow::OSXSetModified',
                            'wxTopLevelWindow::OSXIsModified'
          spec.ignore('wxTopLevelWindow::OSXSetModified','wxTopLevelWindow::OSXIsModified') unless Config.instance.features_set?('__WXOSX__')
          spec.swig_import 'swig/classes/include/wxDefs.h'
          # incorrectly documented here
          spec.override_events 'wxTopLevelWindow',
                               { 'EVT_FULLSCREEN' => ['EVT_FULLSCREEN', 0, 'wxFullScreenEvent'],
                                 'EVT_MAXIMIZE' => ['EVT_MAXIMIZE', 0, 'wxMaximizeEvent'] }
        end
      end
    end # class Frame

  end # class Director

end # module WXRuby3
