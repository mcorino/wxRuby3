// Copyright (c) 2023 M.J.N. Corino, The Netherlands
//
// This software is released under the MIT license.

#include <memory>

/*
 * WxRuby3 App class
 */


#ifdef __WXMSW__
extern "C"
{
  WXDLLIMPEXP_BASE HINSTANCE wxGetInstance();
}
#endif

class wxRubyApp : public wxApp
{
private:
  bool is_running_ = false;
  VALUE self_ = Qnil;
public:
  static wxRubyApp* GetInstance () { return dynamic_cast<wxRubyApp*> (wxApp::GetInstance()); }

  virtual ~wxRubyApp()
  {
#ifdef __WXTRACE__
  std::wcout << "~wxRubyApp" << std::endl;
#endif
    // unlink
    if (this->self_ != Qnil)
    {
      DATA_PTR(this->self_) = 0;
    }
    this->self_ = Qnil;
  }

  // special event handler for destruction of windows which is done
  // automatically by wxWidgets. Tag the object as having been destroyed
  // by WxWidgets.
  void OnWindowDestroy(wxWindowDestroyEvent &event)
  {
    wxObject* wx_obj = event.GetEventObject();
#ifdef __WXRB_DEBUG__
    if (wxRuby_TraceLevel()>0)
      std::wcout << "<= OnWindowDestroy [" << wx_obj << "]" << std::endl;
#endif
    GC_SetWindowDeleted((void *)wx_obj);
    event.Skip();
#ifdef __WXRB_DEBUG__
    if (wxRuby_TraceLevel()>0)
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
    if (wxRuby_TraceLevel()>0)
      std::wcout << "=== Starting App GC mark phase" << std::endl;
#endif

    // If the App has ended, the ruby object will have been unlinked from
    // the C++ one; this implies that all Windows have already been destroyed
    // so there is no point trying to mark them, and doing so may cause
    // errors.
    if ( !wxRubyApp::GetInstance() || !wxRubyApp::GetInstance()->IsRunning() )
    {
#ifdef __WXRB_DEBUG__
      if (wxRuby_TraceLevel()>0)
        std::wcout << "=== App not started yet or has ended, skipping mark phase" << std::endl;
#endif
      return;
    }

    // Mark any active (tracked) log target
    wxLog* curLog = wxLog::GetActiveTarget();
    VALUE rb_cur_log = wxRuby_FindTracking(curLog);
    if (!NIL_P(rb_cur_log))
    {
      rb_gc_mark(rb_cur_log);
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
    if (wxRuby_TraceLevel()>0)
      std::wcout << "=== App GC mark phase completed" << std::endl;
#endif
  }

  // This is the method run when main_loop is called in Ruby
  // wxEntry calls the C++ App::OnInit method
  int main_loop()
  {
    int rc = 0;

    // There should ever only be only a single App instance running
    if (rb_const_defined(mWxCore, rb_intern("THE_APP")))
    {
      rb_raise(rb_eRuntimeError, "There is already another App instance running");
      return -1;
    }

    // Set self reference and global THE_APP constant
    this->self_ = SWIG_RubyInstanceFor(this);
    rb_define_const(mWxCore, "THE_APP", this->self_);
    // Also cache the Ruby App reference on the stack here as after
    // wxEntry returns the C++ App instance will have been destroyed
    // and we cannot reference it (or it's members) anymore
    VALUE the_app = this->self_;

    this->Connect(wxEVT_DESTROY,
          wxWindowDestroyEventHandler(wxRubyApp::OnWindowDestroy));

#ifdef __WXRB_DEBUG__
    if (wxRuby_TraceLevel()>0)
      std::wcout << "Calling wxEntry, this=" << this << std::endl;
#endif

    // collect ruby app name and arguments array
    VALUE rb_args = rb_get_argv();
    int argc = 1 + RARRAY_LEN(rb_args);
    std::unique_ptr<char*[]> argv_safe = std::make_unique<char*[]> (argc);
    VALUE sval = rb_gv_get("$0");
    argv_safe[0] = StringValuePtr(sval);
    for (int i=0; i<RARRAY_LEN(rb_args) ;++i)
    {
      sval = rb_ary_entry(rb_args, i);
      argv_safe[1+i] = StringValuePtr(sval);
    }
    // there is no need to copy the strings as we only need them until
    // wxEntry returns

#ifdef __WXMSW__
    // the instance handle is actually set from DllMain
    if (!wxMSWEntryCommon(wxGetInstance(), (int)true))
      rc = -1;
    else
      rc = wxEntry(argc, argv_safe.get());
#else
    rc = wxEntry(argc, argv_safe.get());
#endif

    /*
      At this point the C++ wxRubyApp instance has been destroyed so take care NOT to reference
      it or any of it's members anymore but only unroll the callstack.
     */

#ifdef __WXRB_DEBUG__
    if (wxRuby_TraceLevel()>0)
      std::wcout << "returned from wxEntry..." << std::endl;
#endif
    rb_gc_start();
#ifdef __WXRB_DEBUG__
    if (wxRuby_TraceLevel()>0)
      std::wcout << "survived gc" << std::endl;
#endif

    rb_const_remove(mWxCore, rb_intern("THE_APP"));

    VALUE exc = rb_iv_get(the_app, "@exception");
    if (!NIL_P(exc))
    {
      rb_exc_raise(exc);
    }
    return rc;
  }

  // This method initializes the stock objects (Pens, Brushes, Fonts)
  // before yielding to ruby by calling the App's on_init method.
  // Note that as of wxWidget 2.8, the stock fonts in particular cannot
  // be initialized any earlier than this without crashing
  bool OnInit() override
  {
#ifdef __WXRB_DEBUG__
    if (wxRuby_TraceLevel()>0)
      std::wcout << "OnInit..." << std::endl;
#endif

    if (!wxApp::OnInit())
      return false;

    // Signal that we've started
    this->is_running_ = true;
    // Set up the GDI objects
    Init_wxRubyStockObjects();
    // Get the ruby representation of the App object, and call the
    // ruby on_init method to set up the initial window state
    bool ex_caught = false;
    VALUE result  = wxRuby_Funcall(ex_caught, this->self_, rb_intern("on_ruby_init"), 0, 0);

    if (ex_caught)
    {
#ifdef __WXRB_DEBUG__
      wxRuby_PrintException(result);
#endif
      rb_iv_set(this->self_, "@exception", result);
      result = Qfalse; // exit app
    }

    // If on_init return any (ruby) true value, signal to wxWidgets to
    // enter the main event loop by returning true, else return false
    // which will make wxWidgets exit.
    if ( result == Qfalse || result == Qnil )
    {
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
    if (wxRuby_TraceLevel()>0)
      std::wcout << "OnExit..." << std::endl;
#endif

    // Get the ruby representation of the App object, and call the
    // ruby on_exit method (if any) for application level cleanup
    ID on_exit_id = rb_intern("on_exit");
    if (rb_funcall(this->self_, rb_intern("respond_to?"), 1, ID2SYM(on_exit_id)) == Qtrue)
    {
      bool ex_caught = false;
      VALUE rc = wxRuby_Funcall(ex_caught, this->self_, on_exit_id, 0, 0);
      if (ex_caught)
      {
#ifdef __WXRB_DEBUG__
        wxRuby_PrintException(rc);
#endif
        rb_iv_set(this->self_, "@exception", rc);
      }
    }

    // perform wxRuby cleanup
    _wxRuby_Cleanup();

    // execute base wxWidgets functionality
    return this->wxApp::OnExit();
  }

  // actually implemented in ruby in classes/app.rb
  virtual void OnAssertFailure(const wxChar *file, int line, const wxChar *func, const wxChar *cond, const wxChar *msg) override
  {
    if (rb_during_gc() || NIL_P(this->self_))
    {
      std::wcerr << file << "(" << line << "): ASSERT " << cond
                 << (NIL_P(this->self_) ? " fired without THE_APP in " : " fired during GC phase in ")
                 << func << "() with message [" << msg << "]" << std::endl;
    }
    else
    {
      VALUE obj0 = Qnil ;
      VALUE obj1 = Qnil ;
      VALUE obj2 = Qnil ;
      VALUE obj3 = Qnil ;
      VALUE obj4 = Qnil ;

      obj0 = rb_str_new2((const char *)wxString(file).utf8_str());
      obj1 = INT2NUM(line);
      obj2 = rb_str_new2((const char *)wxString(func).utf8_str());
      obj3 = rb_str_new2((const char *)wxString(cond).utf8_str());
      obj4 = rb_str_new2((const char *)wxString(msg).utf8_str());
      (void)wxRuby_Funcall(this->self_, rb_intern("on_assert_failure"), 5,obj0,obj1,obj2,obj3,obj4);
    }
  }

  void _wxRuby_Cleanup()
  {
#ifdef __WXRB_DEBUG__
    if (wxRuby_TraceLevel()>0)
      std::wcout << "wxRuby_Cleanup..." << std::endl;
#endif
    // Note in a global variable that the App has ended, so that we
    // can skip any GC marking later
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
