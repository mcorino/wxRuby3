# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './window'

module WXRuby3

  class Director

    class TopLevelWindow < Window

      def setup
        super
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
          # #ignore_unless if wxRuby one day supports 'WXUNIVERSAL'
          spec.ignore %w{
            wxTopLevelWindow::IsUsingNativeDecorations
            wxTopLevelWindow::UseNativeDecorations
            wxTopLevelWindow::UseNativeDecorationsByDefault
            }
          spec.ignore_unless('WXMSW', 'wxTopLevelWindow::MSWGetSystemMenu')
          spec.ignore_unless('WXOSX', 'wxTopLevelWindow::OSXSetModified','wxTopLevelWindow::OSXIsModified')
          spec.swig_import 'swig/classes/include/wxDefs.h'
          # incorrectly documented here
          spec.override_events 'wxTopLevelWindow',
                               { 'EVT_FULLSCREEN' => ['EVT_FULLSCREEN', 0, 'wxFullScreenEvent'],
                                 'EVT_MAXIMIZE' => ['EVT_MAXIMIZE', 0, 'wxMaximizeEvent'] }
        end
      end

      def process(gendoc: false)
        defmod = super
        # for all wxTopLevelWindow (derived) classes
        spec.items.each do |citem|
          def_item = defmod.find_item(citem)
          if Extractor::ClassDef === def_item && (citem == 'wxTopLevelWindow' || spec.is_derived_from?(def_item, 'wxTopLevelWindow'))
            spec.no_proxy("#{spec.class_name(citem)}::ClearBackground",
                          "#{spec.class_name(citem)}::Enable",
                          "#{spec.class_name(citem)}::EnableCloseButton",
                          "#{spec.class_name(citem)}::GetHelpTextAtPoint",
                          "#{spec.class_name(citem)}::GetMaxSize",
                          "#{spec.class_name(citem)}::GetMinSize",
                          "#{spec.class_name(citem)}::GetTitle",
                          "#{spec.class_name(citem)}::Iconize",
                          "#{spec.class_name(citem)}::IsActive",
                          "#{spec.class_name(citem)}::IsFullScreen",
                          "#{spec.class_name(citem)}::IsMaximzed",
                          "#{spec.class_name(citem)}::IsAlwaysMaximzed",
                          #"#{spec.class_name(citem)}::IsTopLevel",
                          "#{spec.class_name(citem)}::IsVisible",
                          "#{spec.class_name(citem)}::Maximize",
                          "#{spec.class_name(citem)}::Navigate",
                          "#{spec.class_name(citem)}::Refresh",
                          "#{spec.class_name(citem)}::Reparent",
                          "#{spec.class_name(citem)}::RequestUserAttention",
                          "#{spec.class_name(citem)}::Restore",
                          "#{spec.class_name(citem)}::SetIcon",
                          "#{spec.class_name(citem)}::SetIcons",
                          #"#{spec.class_name(citem)}::SetMaxSize",
                          #"#{spec.class_name(citem)}::SetMinSize",
                          "#{spec.class_name(citem)}::SetShape",
                          "#{spec.class_name(citem)}::SetSize",
                          "#{spec.class_name(citem)}::SetSize",
                          #"#{spec.class_name(citem)}::SetSizeHints",
                          #"#{spec.class_name(citem)}::SetSizeHints",
                          "#{spec.class_name(citem)}::SetTitle",
                          #"#{spec.class_name(citem)}::SetTransparent",
                          #"#{spec.class_name(citem)}::Show",
                          "#{spec.class_name(citem)}::ShowFullScreen",
                          "#{spec.class_name(citem)}::Update",
                          "#{spec.class_name(citem)}::UpdateWindow",
                          "#{spec.class_name(citem)}::Validate")
          end
        end
        defmod
      end

    end # class Frame

  end # class Director

end # module WXRuby3
