#--------------------------------------------------------------------
# @file    app.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

module WXRuby3

  class Director

    class App < Director

      def setup
        spec.items << 'wxAppConsole'
        spec.fold_bases('wxApp' => 'wxAppConsole')
        spec.ignore_bases('wxAppConsole' => 'wxEventFilter')
        spec.ignore %w{
          wxApp.ProcessMessage
          wxApp::GetGUIInstance
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
          wxAppConsole::argc
          wxAppConsole::argv
          wxDECLARE_APP
          wxIMPLEMENT_APP
          wxIMPLEMENT_APP_CONSOLE
          wxIMPLEMENT_WXWIN_MAIN
          wxIMPLEMENT_WXWIN_MAIN_CONSOLE
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
        unless Config.instance.wx_abi_version >= '3.2.1' || Config.instance.wx_version < '3.2.1'
          spec.ignore 'wxApp::GTKAllowDiagnosticsControl'
        end
        spec.extend_class('wxApp', 'int main_loop ()')
        spec.ignore [
          'wxEntry(int &,wxChar **)',
          'wxEntry(HINSTANCE,HINSTANCE,char *,int)'
        ]
        spec.no_proxy %w{
          wxRubyApp::GetDisplayMode
          wxRubyApp::GetTopWindow
          wxRubyApp::OnInit
          wxRubyApp::OnExit
        }
        spec.include %w{
          wx/init.h
          wx/display.h
        }
        spec.gc_never
        spec.rename_class('wxApp', 'wxRubyApp')
        spec.rename_for_ruby(
          'OnCInit' =>
            'wxRubyApp::OnInit()')
        spec.add_swig_code <<~__HEREDOC
          // The App class in wxRuby is actually a custom-written subclass, but it
          // is presented to the user as Wx::App
          %rename(App) wxRubyApp;
          
          // Leave GC type at GC_NEVER but add a custom marker.
          // Prevents the App being destroyed prematurely when Ruby exits down with
          // an exception. Otherwise GC destroys the C++ object, which can still
          // be needed for final WxWidgets events.
          %markfunc wxRubyApp "wxRubyApp::mark_wxRubyApp";
          __HEREDOC
        spec.add_header_code <<~__HEREDOC
          extern void GC_SetWindowDeleted(void*);
          extern "C" void Init_wxRubyStockObjects();
          extern void wxRuby_MarkProtectedEvtHandlerProcs();
          
          class wxRubyApp : public wxApp
          {
          
          public:
          
          
            virtual ~wxRubyApp()
            {
          #ifdef __WXTRACE__
            std::wcout << "~wxRubyApp" << std::endl;
          #endif
              }
          
            // special event handler for destruction of windows which is done
            // automatically by wxWidgets. Tag the object as having been destroyed
            // by WxWidgets.
            void OnWindowDestroy(wxWindowDestroyEvent &event)
            {
              wxObject* wx_obj = event.GetEventObject();
              GC_SetWindowDeleted((void *)wx_obj);
              event.Skip();
            }
          
            // When ruby's garbage collection runs, if the app is still active, it
            // cycles through all currently known SWIG objects and calls this
            // function on each to preserve still active Wx::Windows, and also
            // pending Wx::Events which have been queued from the Ruby side (the
            // only sort of events that will be in the tracking hash.
            static void markIterate(void* ptr, VALUE rb_obj)
            {
              // Check if it's a valid object (sometimes SWIG doesn't return what we're
              // expecting), a descendant of Wx::Window, and if it has not yet been
              // deleted by WxWidgets; if so, mark it.
              if ( TYPE(rb_obj) == T_DATA )
              {
                if ( rb_obj_is_kind_of(rb_obj, wxRuby_GetWindowClass()) )
                  rb_gc_mark(rb_obj);
                else if (rb_obj_is_kind_of(rb_obj, wxRuby_GetDefaultEventClass()) )
                  rb_gc_mark(rb_obj);
              }
            }
          
            // Implements GC protection across wxRuby. Always called because
            // Wx::THE_APP is a constant so always checked in GC mark phase.
            static void mark_wxRubyApp(void *ptr)
            {
          
          #ifdef __WXRB_DEBUG__
              std::wcout << "=== Starting App GC mark phase" << std::endl;
          #endif
          
              // If the App has ended, the ruby object will have been unlinked from
              // the C++ one; this implies that all Windows have already been destroyed
              // so there is no point trying to mark them, and doing so may cause
              // errors.
              if ( rb_gv_get("__wx_app_ended__" ) == Qtrue )
              {
          #ifdef __WXRB_DEBUG__
                std::wcout << "=== App has ended, skipping mark phase" << std::endl;
          #endif
                return;
              }
          
              // Mark evt handler procs associated with live windows - see
              // classes/EvtHandler.i
              wxRuby_MarkProtectedEvtHandlerProcs();
          
              // To do the main marking, primarily of Windows, iterate over SWIG's
              // list of tracked objects
              wxRuby_IterateTracking(&wxRubyApp::markIterate);
          
          #ifdef __WXRB_DEBUG__
              std::wcout << "=== App GC mark phase completed" << std::endl;
          #endif
            }
          
            // This is the method run when main_loop is called in Ruby
            // wxEntry calls the C++ App::OnInit method
            int main_loop()
            {
              rb_define_const(#{spec.package.module_variable}, "THE_APP", SWIG_RubyInstanceFor(this));
          #ifndef __WXMSW__
              static int argc = 1;
              static wxChar *argv[] = {const_cast<wxChar*> (wxT("wxruby")), NULL};
          #endif
              this->Connect(wxEVT_DESTROY,
                    wxWindowDestroyEventHandler(wxRubyApp::OnWindowDestroy));
          
          #ifdef __WXRB_DEBUG__
              std::wcout << "Calling wxEntry, this=" << this << std::endl;
          #endif
          
          #ifdef __WXMSW__
              extern int wxEntry(HINSTANCE hInstance,
                         HINSTANCE WXUNUSED(hPrevInstance),
                         wxCmdLineArgType WXUNUSED(pCmdLine),
                         int nCmdShow);
              wxEntry(GetModuleHandle(NULL),(HINSTANCE)0,(wxCmdLineArgType)"",(int)true);
          #else
              wxEntry(argc, argv);
          #endif
          
          #ifdef __WXRB_DEBUG__
              std::wcout << "returned from wxEntry..." << std::endl;
          #endif
              rb_gc_start();
          #ifdef __WXRB_DEBUG__
              std::wcout << "survived gc" << std::endl;
          #endif
              return 0;
            }
          
            // This method initializes the stock objects (Pens, Brushes, Fonts)
            // before yielding to ruby by calling the App's on_init method.
            // Note that as of wxWidget 2.8, the stock fonts in particular cannot
            // be initialized any earlier than this without crashing
            bool OnInit()
            {
          #ifdef __WXRB_DEBUG__
              std::wcout << "OnInit..." << std::endl;
          #endif
              // Signal that we're started
              rb_gv_set("__wx_app_ended__", Qfalse);
              // Set up the GDI objects
              Init_wxRubyStockObjects();
              // Get the ruby representation of the App object, and call the
              // ruby on_init method to set up the initial window state
              VALUE the_app = rb_const_get(#{spec.package.module_variable}, rb_intern("THE_APP"));
              VALUE result  = rb_funcall(the_app, rb_intern("on_ruby_init"), 0, 0);
        
              // If on_init return any (ruby) true value, signal to wxWidgets to
              // enter the main event loop by returning true, else return false
              // which will make wxWidgets exit.
              if ( result == Qfalse || result == Qnil )
              {
                rb_gv_set("__wx_app_ended__", Qtrue); // Don't do any more GC
                return false;
              }
              else
              {
                return true;
              }
            }
          
            virtual int OnExit()
            {
          #ifdef __WXRB_DEBUG__
              std::wcout << "OnExit..." << std::endl;
          #endif
              // Note in a global variable that the App has ended, so that we
              // can skip any GC marking later
              rb_gv_set("__wx_app_ended__", Qtrue);
      
              wxLog *oldlog = wxLog::SetActiveTarget(new wxLogStderr);
              SetTopWindow(0);
              if ( oldlog )
              {
                delete oldlog;
              }
      
              return 0;
            }
          
            // actually implemented in ruby in classes/app.rb
            virtual void OnAssertFailure(const wxChar *file, int line, const wxChar *func, const wxChar *cond, const wxChar *msg)
            {
              std::wcout << "ASSERT fired" << std::endl;
            }
          };
          __HEREDOC
        super
      end
    end

  end # class Director

end # module WXRuby3
