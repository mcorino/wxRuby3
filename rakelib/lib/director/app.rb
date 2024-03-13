# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './event_handler'

module WXRuby3

  class Director

    class App < EvtHandler

      def setup
        spec.items << 'wxAppConsole' << 'wxEventFilter'
        if Config.instance.wx_version >= '3.3.0'
          spec.items << 'wxDarkModeSettings'
          spec.ignore_unless('WXMSW', 'wxDarkModeSettings', 'wxMenuColour')
          if Config.instance.features_set?('WXMSW')
            spec.disown 'wxDarkModeSettings *settings'
            # wxDarkModeSettings does has have virt dtor; it's just not documented
            spec.suppress_warning(514, 'wxDarkModeSettings')
          end
        end
        spec.fold_bases('wxApp' => 'wxAppConsole', 'wxAppConsole' => 'wxEventFilter')
        spec.override_inheritance_chain('wxApp', %w[wxEvtHandler wxObject])
        spec.ignore %w{
          wxApp::ProcessMessage
          wxApp::SetDisplayMode
          wxApp::GetDisplayMode
          wxAppConsole::OnInit
          wxAppConsole::OnExit
          wxAppConsole::OnRun
          wxAppConsole.OnFatalException
          wxAppConsole::OnExceptionInMainLoop
          wxAppConsole::OnUnhandledException
          wxAppConsole::StoreCurrentException
          wxAppConsole::RethrowStoredException
          wxAppConsole::OnEventLoopEnter
          wxAppConsole::OnEventLoopExit
          wxAppConsole::OnCmdLineError
          wxAppConsole::OnCmdLineHelp
          wxAppConsole::OnCmdLineParsed
          wxAppConsole::OnInitCmdLine
          wxAppConsole::MainLoop
          wxAppConsole::GetMainLoop
          wxAppConsole::HandleEvent
          wxAppConsole::ScheduleForDestruction
          wxAppConsole::IsScheduledForDestruction
          wxAppConsole::SetInstance
          wxAppConsole::GetInstance
          wxAppConsole::CreateTraits
          wxAppConsole::argc
          wxAppConsole::argv
          wxDECLARE_APP
          wxIMPLEMENT_APP
          wxDISABLE_DEBUG_SUPPORT
          wxTheApp
          wxGetApp
          wxHandleFatalExceptions
          wxInitialize
          wxUninitialize
          wxWakeUpIdle
          wxYield
          wxSafeYield
          wxExit
        }
        spec.ignore 'wxApp::GetGUIInstance'
        unless Config.instance.wx_abi_version >= '3.2.1' || Config.instance.wx_version < '3.2.1'
          spec.ignore 'wxApp::GTKAllowDiagnosticsControl'
        end
        spec.add_extend_code 'wxApp', <<~__HEREDOC
          int main_loop()
          {
            return dynamic_cast<wxRubyApp*>(self)->main_loop();
          }
          void _wxRuby_Cleanup()
          {
            dynamic_cast<wxRubyApp*>(self)->_wxRuby_Cleanup();
          }
          bool IsRunning() const
          {
            return dynamic_cast<const wxRubyApp*>(self)->IsRunning();
          }
          __HEREDOC
        if Config.platform == :macosx
          # add static accessor methods for the standard OSX menu items
          spec.add_extend_code 'wxApp', <<~__HEREDOC
            static void set_mac_about_menu_itemid(long menu_itemid)
            {
              wxApp::s_macAboutMenuItemId = menu_itemid;
            }
            static long get_mac_about_menu_itemid(long menu_itemid)
            {
              return wxApp::s_macAboutMenuItemId;
            }
            static void set_mac_preferences_menu_itemid(long menu_itemid)
            {
              wxApp::s_macPreferencesMenuItemId = menu_itemid;
            }
            static long get_mac_preferences_menu_itemid(long menu_itemid)
            {
              return wxApp::s_macPreferencesMenuItemId;
            }
            static void set_mac_exit_menu_itemid(long menu_itemid)
            {
              wxApp::s_macExitMenuItemId = menu_itemid;
            }
            static long get_mac_exit_menu_itemid(long menu_itemid)
            {
              return wxApp::s_macExitMenuItemId;
            }
            static void set_mac_help_menu_title(const wxString& title)
            {
              wxApp::s_macHelpMenuTitleName = title;
            }
            static const wxString& get_mac_help_menu_title()
            {
              return wxApp::s_macHelpMenuTitleName;
            }
            static void set_mac_window_menu_title(const wxString& title)
            {
              wxApp::s_macWindowMenuTitleName = title;
            }
            static const wxString& get_mac_help_window_title()
            {
              return wxApp::s_macWindowMenuTitleName;
            }
            __HEREDOC
        end
        spec.ignore [
          'wxEntry(int &,wxChar **)',
          'wxEntry(HINSTANCE,HINSTANCE,char *,int)'
        ]
        spec.no_proxy %w{
          wxApp::GetDisplayMode
          wxApp::GetTopWindow
          wxApp::OnAssertFailure
        }
        spec.include %w{
          wx/init.h
          wx/display.h
        }
        spec.gc_never
        # make Ruby director and wrappers use custom implementation
        spec.use_class_implementation('wxApp', 'wxRubyApp')
        spec.add_swig_code <<~__HEREDOC
          // Leave GC type at GC_NEVER but add a custom marker.
          // Prevents the App being destroyed prematurely when Ruby exits down with
          // an exception. Otherwise GC destroys the C++ object, which can still
          // be needed for final WxWidgets events.
          %markfunc wxApp "wxRubyApp::mark_wxRubyApp";
          __HEREDOC
        spec.add_header_code <<~__HEREDOC
          extern void GC_SetWindowDeleted(void*);
          extern "C" void Init_wxRubyStockObjects();
          extern void wxRuby_MarkProtectedEvtHandlerProcs();

          static wxVector<WXRBMarkFunction> WXRuby_Mark_List;

          WXRUBY_EXPORT void wxRuby_AppendMarker(WXRBMarkFunction marker)
          {
            WXRuby_Mark_List.push_back(marker);
          }

          #include "wxRubyApp.h"          

          WXRUBY_EXPORT bool wxRuby_IsAppRunning()
          {
            return wxRubyApp::GetInstance() && wxRubyApp::GetInstance()->IsRunning();  
          }

          WXRUBY_EXPORT void wxRuby_ExitMainLoop(VALUE exception)
          {
            if (wxRubyApp::GetInstance() && wxRubyApp::GetInstance()->IsRunning())
            {
              if (!NIL_P(exception))
              {
                VALUE the_app = rb_const_get(#{spec.package.module_variable}, rb_intern("THE_APP"));
                rb_iv_set(the_app, "@exception", exception);
              }
              wxRubyApp::GetInstance()->ExitMainLoop();
            }  
          }

          WXRUBY_EXPORT void wxRuby_PrintException(VALUE err)
          {
            static WxRuby_ID message_id("message");
            static WxRuby_ID class_id("class");
            static WxRuby_ID name_id("name");
            static WxRuby_ID backtrace_id("backtrace");
            static WxRuby_ID join_id("join");
          
            VALUE msg = rb_funcall(err, message_id(), 0);
            VALUE err_name = rb_funcall(rb_funcall(err, class_id(), 0), name_id(), 0);
            VALUE bt = rb_funcall(err, backtrace_id(), 0);
            bt = rb_funcall(bt, join_id(), 1, rb_str_new2("\\n\\tfrom "));
            std::cerr << std::endl
                      << ' ' << StringValuePtr(msg) << '(' << StringValuePtr(err_name) << ')' << std::endl
                      << "\\tfrom " << StringValuePtr(bt) << std::endl << std::endl;
          }
          __HEREDOC
        super
      end

      def process(gendoc: false)
        defmod = super
        # fix documentation errors for generic dirctrl events
        def_item = defmod.find_item('wxApp')
        if def_item
          def_item.event_types.each do |evt_spec|
            case evt_spec.first
            when 'EVT_DIALUP_CONNECTED', 'EVT_DIALUP_DISCONNECTED'
              if evt_spec[3].nil?
                evt_spec[3] = 'wxDialUpEvent' # missing from docs
              end
            end
          end
        end
        defmod
      end

    end

  end # class Director

end # module WXRuby3
