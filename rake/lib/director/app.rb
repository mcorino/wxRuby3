###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './event_handler'

module WXRuby3

  class Director

    class App < EvtHandler

      def setup
        spec.items << 'wxAppConsole'
        spec.fold_bases('wxApp' => 'wxAppConsole')
        spec.override_inheritance_chain('wxApp', %w[wxEvtHandler wxObject])
        spec.ignore %w{
          wxApp.ProcessMessage
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
        if Config.instance.wx_version > '3.1.5'
          spec.ignore 'wxApp::GetGUIInstance'
        end
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
        spec.ignore [
          'wxEntry(int &,wxChar **)',
          'wxEntry(HINSTANCE,HINSTANCE,char *,int)'
        ]
        spec.no_proxy %w{
          wxApp::GetDisplayMode
          wxApp::GetTopWindow
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
          
          class wxRubyApp : public wxApp
          {
          private:
            static wxRubyApp* instance_;

            bool is_running_ = false;
          public:
            static wxRubyApp* GetInstance () { return instance_; }

            virtual ~wxRubyApp()
            {
          #ifdef __WXTRACE__
            std::wcout << "~wxRubyApp" << std::endl;
          #endif
              // unlink
              VALUE the_app = rb_const_get(#{spec.package.module_variable}, rb_intern("THE_APP"));
              if (the_app != Qnil) 
              {
                DATA_PTR(the_app) = 0;
              }
            }
          
            // special event handler for destruction of windows which is done
            // automatically by wxWidgets. Tag the object as having been destroyed
            // by WxWidgets.
            void OnWindowDestroy(wxWindowDestroyEvent &event)
            {
              wxObject* wx_obj = event.GetEventObject();
          #ifdef __WXRB_DEBUG__
              std::wcout << "<= OnWindowDestroy [" << wx_obj << "]" << std::endl;
          #endif
              GC_SetWindowDeleted((void *)wx_obj);
              event.Skip();
          #ifdef __WXRB_DEBUG__
              std::wcout << "=> OnWindowDestroy [" << wx_obj << "]" << std::endl;
          #endif
            }

            bool IsRunning() const { return this->is_running_; }
          
            // When ruby's garbage collection runs, if the app is still active, it
            // cycles through all currently known SWIG objects and calls this
            // function on each to preserve still active Wx::Windows, and also
            // pending Wx::Events which have been queued from the Ruby side (the
            // only sort of events that will be in the tracking hash.
            static void markIterate(void* ptr, VALUE rb_obj)
            {
              // Check if it's a valid object (sometimes SWIG doesn't return what we're
              // expecting), a descendant of Wx::Window (but not a Dialog), and if it has not yet been
              // deleted by WxWidgets; if so, mark it.
              if ( TYPE(rb_obj) == T_DATA )
              {
                if ( rb_obj_is_kind_of(rb_obj, wxRuby_GetWindowClass()) )
                {
                  rb_gc_mark(rb_obj);
                }
                else if (rb_obj_is_kind_of(rb_obj, wxRuby_GetDefaultEventClass()) )
                  rb_gc_mark(rb_obj);
              }
              else if (TYPE(rb_obj) == T_ARRAY )
              {
                VALUE proc = rb_ary_entry(rb_obj, 0);
                if (rb_obj_is_kind_of(proc, rb_cProc) || rb_obj_is_kind_of(proc, rb_cMethod))
                {
                  // keep the async call alive
                  rb_gc_mark(rb_obj);
                }
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
              if ( !wxRubyApp::GetInstance() || !wxRubyApp::GetInstance()->IsRunning() )
              {
          #ifdef __WXRB_DEBUG__
                std::wcout << "=== App has ended, skipping mark phase" << std::endl;
          #endif
                return;
              }
          
              // Mark evt handler procs associated with live windows - see
              // classes/EvtHandler.i
              wxRuby_MarkProtectedEvtHandlerProcs();

              // run registered markers
              for (wxVector<WXRBMarkFunction>::iterator it = WXRuby_Mark_List.begin();
                    it != WXRuby_Mark_List.end() ;++it)
              {
                (*it) ();
              }
          
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
              VALUE rb_app = SWIG_RubyInstanceFor(this);
              rb_define_const(#{spec.package.module_variable}, "THE_APP", rb_app);
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
              wxEntry(GetModuleHandle("#{spec.package.libname}.#{RbConfig::CONFIG['DLEXT']}"),
                      (HINSTANCE)0,
                      (wxCmdLineArgType)"",
                      (int)true);
          #else
              int argc = 0;
              char** argv = 0;
              wxEntry(argc, argv);
          #endif
          
              rb_const_remove(#{spec.package.module_variable}, rb_intern("THE_APP"));

          #ifdef __WXRB_DEBUG__
              std::wcout << "returned from wxEntry..." << std::endl;
          #endif
              rb_gc_start();
          #ifdef __WXRB_DEBUG__
              std::wcout << "survived gc" << std::endl;
          #endif

              VALUE exc = rb_iv_get(rb_app, "@exception");
              if (!NIL_P(exc))
              {
                rb_exc_raise(exc);
              }
              return 0;
            }
          
            // This method initializes the stock objects (Pens, Brushes, Fonts)
            // before yielding to ruby by calling the App's on_init method.
            // Note that as of wxWidget 2.8, the stock fonts in particular cannot
            // be initialized any earlier than this without crashing
            bool OnInit() override
            {
          #ifdef __WXRB_DEBUG__
              std::wcout << "OnInit..." << std::endl;
          #endif
              // set standard App name
              this->SetAppName(wxString("wxruby"));
              // Signal that we've started              
              wxRubyApp::instance_ = this; // there should ALWAYS EVER be only 1 app instance running/created
              this->is_running_ = true;
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
                wxRubyApp::instance_ = 0;
                this->is_running_ = false;
                return false;
              }
              else
              {
                return true;
              }
            }
          
            int OnExit() override
            {
          #ifdef __WXRB_DEBUG__
              std::wcout << "OnExit..." << std::endl;
          #endif

              // Get the ruby representation of the App object, and call the
              // ruby on_exit method (if any) for application level cleanup
              VALUE the_app = rb_const_get(#{spec.package.module_variable}, rb_intern("THE_APP"));
              ID on_exit_id = rb_intern("on_exit");
              if (rb_funcall(the_app, rb_intern("respond_to?"), 1, ID2SYM(on_exit_id)) == Qtrue)
              {
                rb_funcall(the_app, on_exit_id, 0, 0);
              }

              // perform wxRuby cleanup
              _wxRuby_Cleanup();
      
              // execute base wxWidgets functionality 
              return this->wxApp::OnExit();
            }
          
            // actually implemented in ruby in classes/app.rb
            virtual void OnAssertFailure(const wxChar *file, int line, const wxChar *func, const wxChar *cond, const wxChar *msg)
            {
              std::wcout << "ASSERT fired" << std::endl;
            }

            void _wxRuby_Cleanup()
            {
          #ifdef __WXRB_DEBUG__
              std::wcout << "wxRuby_Cleanup..." << std::endl;
          #endif
              // Note in a global variable that the App has ended, so that we
              // can skip any GC marking later
              wxRubyApp::instance_ = 0;
              this->is_running_ = false;
      
              // if a Ruby implemented logger has been installed clean that up
              // before we exit, otherwise let wxWidgets handle things
              wxLog *oldlog = wxLog::GetActiveTarget();
              if (wxRuby_FindTracking(oldlog) != Qnil)
              {
                oldlog = wxLog::SetActiveTarget(new wxLogStderr);
              }
              else
              {
                oldlog = 0;
              }
              SetTopWindow(0);
              if ( oldlog )
              {
                SWIG_RubyUnlinkObjects(oldlog);
                SWIG_RubyRemoveTracking(oldlog);
                delete oldlog;
              }
            }
          };
          wxRubyApp* wxRubyApp::instance_ = 0;

          WXRUBY_EXPORT bool wxRuby_IsAppRunning()
          {
            return wxRubyApp::GetInstance() != 0 && wxRubyApp::GetInstance()->IsRunning();  
          }
          __HEREDOC
        super
      end
    end

  end # class Director

end # module WXRuby3
