// Copyright (c) 2023 M.J.N. Corino, The Netherlands
//
// This software is released under the MIT license.

WXRUBY_TRACE_GUARD(WxRubyTraceWinDestroy, "WINDOW_DESTROY")
WXRUBY_TRACE_GUARD(WxRubyTraceMarkApp, "GC_MARK_APP")
WXRUBY_TRACE_GUARD(WxRubyTraceAppRun, "APP_RUN")

#include <memory>

#include <ruby/ractor.h>

#include <wx/scopedptr.h>
#include <wx/evtloop.h>

// this defines wxEventLoopPtr
wxDEFINE_TIED_SCOPED_PTR_TYPE(wxEventLoopBase)

/*
 * WxRuby3 App class
 */

class wxRubyApp : public wxApp
{
private:
  bool is_running_ = false;
  VALUE self_ = Qnil;

  void _store_ruby_exception(VALUE ex)
  {
    rb_iv_set(this->self_, "@exception", ex);
  }

  class EventLoop : public wxGUIEventLoop
  {
  public:
    int GetExitCode() { return this->exit_code_; }

  protected:
    virtual int DoRun() override
    {
      static WxRuby_ID count_id("count");
      static WxRuby_ID list_id("list");
      static WxRuby_ID pass_id("pass");

      // run our own event loop
      for (;;)
      {
        while ( !m_shouldExit
                    && !Pending()
                        && !(wxTheApp && wxTheApp->HasPendingEvents()) )
        {
          // check Ruby Ractors and/or Threads
          bool needs_pass = false;
          VALUE result  = rb_funcall(rb_cRactor, count_id(), 0);
          needs_pass = !RB_NIL_P(result) && NUM2INT(result) > 1;
          if (!needs_pass)
          {
            result = rb_funcall(rb_cThread, list_id(), 0);
            needs_pass = !RB_NIL_P(result) && TYPE(result) == T_ARRAY && RARRAY_LEN(result) > 1;
          }
          if (needs_pass)
          {
            // call Thread.pass
            bool ex_caught = false;
            result  = wxRuby_Funcall(ex_caught, rb_cThread, pass_id(), 0, 0);
            if (ex_caught)
            {
#ifdef __WXRB_DEBUG__
              wxRuby_PrintException(result);
#endif
              wxRubyApp::GetInstance()->_store_ruby_exception(result);
              this->exit_code_ = 1;
              m_shouldExit = true;
            }
          }

          if (!m_shouldExit)
          {
            if (!ProcessIdle())
              break;
          }
        }

        // if Exit() was called, don't dispatch any more events here
        if (m_shouldExit)
            break;

        // process pending wx events first as they correspond to low-level events
        // which happened before, i.e. typically pending events were queued by a
        // previous call to Dispatch() and if we didn't process them now the next
        // call to it might enqueue them again (as happens with e.g. socket events
        // which would be generated as long as there is input available on socket
        // and this input is only removed from it when pending event handlers are
        // executed)
        if ( wxTheApp )
        {
            wxTheApp->ProcessPendingEvents();

            // One of the pending event handlers could have decided to exit the
            // loop so check for the flag before trying to dispatch more events
            // (which could block indefinitely if no more are coming).
            if ( m_shouldExit )
                break;
        }

        // nothing doing, so just wait max 1 msec for an event
        if (this->DispatchTimeout(1) == 0 && m_shouldExit)
          break; // stop event loop

      }

      return this->exit_code_;
    }

    virtual void DoStop(int rc) override
    {
      this->exit_code_ = rc;
#if !defined(__WXGTK__)
      wxGUIEventLoop::DoStop(rc);
#endif
    }

  private:
    int exit_code_ {};
  };

public:
  static wxRubyApp* GetInstance () { return dynamic_cast<wxRubyApp*> (wxApp::GetInstance()); }

  virtual ~wxRubyApp()
  {
    WXRUBY_TRACE_IF(WxRubyTraceAppRun, 1)
      WXRUBY_TRACE("> ~wxRubyApp this=" << this)
    WXRUBY_TRACE_END

    // app is also event handler, so cleanup
    wxRuby_ReleaseEvtHandlerProcs(this);

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

    WXRUBY_TRACE_IF(WxRubyTraceWinDestroy, 1)
      WXRUBY_TRACE("< OnWindowDestroy [" << wx_obj << "]")
    WXRUBY_TRACE_END

    GC_SetWindowDeleted((void *)wx_obj);
    event.Skip();

    WXRUBY_TRACE_IF(WxRubyTraceWinDestroy, 1)
      WXRUBY_TRACE("> OnWindowDestroy [" << wx_obj << "]")
    WXRUBY_TRACE_END
  }

  bool IsRunning() const { return this->is_running_; }

  // Implements GC protection across wxRuby. Always called because
  // Wx::THE_APP is a constant so always checked in GC mark phase.
  static void GC_mark_wxRubyApp(void *ptr)
  {
    WXRUBY_TRACE_IF(WxRubyTraceMarkApp, 1)
      WXRUBY_TRACE(">=== Starting App GC mark phase")
    WXRUBY_TRACE_END

    // If the App has ended, the ruby object will have been unlinked from
    // the C++ one; this implies that all Windows have already been destroyed
    // so there is no point trying to mark them, and doing so may cause
    // errors.
    if ( !wxRubyApp::GetInstance() || !wxRubyApp::GetInstance()->IsRunning() )
    {
      WXRUBY_TRACE_IF(WxRubyTraceMarkApp, 1)
        WXRUBY_TRACE("<=== App not started yet or has ended, skipping mark phase")
      WXRUBY_TRACE_END
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

    // Mark all tracked objects (as applicable)
    wxRuby_MarkTracked();

    WXRUBY_TRACE_IF(WxRubyTraceMarkApp, 1)
      WXRUBY_TRACE("<=== App GC mark phase completed")
    WXRUBY_TRACE_END
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

    WXRUBY_TRACE_IF(WxRubyTraceAppRun, 1)
      WXRUBY_TRACE("> main_loop : Calling wxEntry, this=" << this)
    WXRUBY_TRACE_END

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
    wxApp::m_nCmdShow = SW_NORMAL;
#endif
    rc = wxEntry(argc, argv_safe.get());

    /*
      At this point the C++ wxRubyApp instance has been destroyed so take care NOT to reference
      it or any of it's members anymore but only unroll the callstack.
     */

    WXRUBY_TRACE_IF(WxRubyTraceAppRun, 1)
      WXRUBY_TRACE("| main_loop : returned from wxEntry...")
    WXRUBY_TRACE_END
    rb_gc_start();
    WXRUBY_TRACE_IF(WxRubyTraceAppRun, 1)
      WXRUBY_TRACE("| main_loop : survived gc")
    WXRUBY_TRACE_END

    rb_const_remove(mWxCore, rb_intern("THE_APP"));

    VALUE exc = rb_iv_get(the_app, "@exception");
    if (!NIL_P(exc))
    {
      rb_exc_raise(exc);
    }

    WXRUBY_TRACE_IF(WxRubyTraceAppRun, 1)
      WXRUBY_TRACE("< main_loop")
    WXRUBY_TRACE_END

    return rc;
  }

  virtual int MainLoop() override
  {
    wxEventLoopBaseTiedPtr main_loop(&m_mainLoop, new wxRubyApp::EventLoop);

    if (wxTheApp)
        wxTheApp->OnLaunched();

    return m_mainLoop ? m_mainLoop->Run() : -1;
  }

  // This method initializes the stock objects (Pens, Brushes, Fonts)
  // before yielding to ruby by calling the App's on_init method.
  // Note that as of wxWidget 2.8, the stock fonts in particular cannot
  // be initialized any earlier than this without crashing
  bool OnInit() override
  {
    WXRUBY_TRACE_IF(WxRubyTraceAppRun, 1)
      WXRUBY_TRACE("> OnInit")
    WXRUBY_TRACE_END

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
      _store_ruby_exception(result);
      result = Qfalse; // exit app
    }

    WXRUBY_TRACE_IF(WxRubyTraceAppRun, 1)
      WXRUBY_TRACE("< OnInit -> " << ((result == Qfalse || result == Qnil) ? "false" : "true"))
    WXRUBY_TRACE_END

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
    WXRUBY_TRACE_IF(WxRubyTraceAppRun, 1)
      WXRUBY_TRACE("> OnExit")
    WXRUBY_TRACE_END

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
        _store_ruby_exception(rc);
      }
    }

    // perform wxRuby cleanup
    _wxRuby_Cleanup();

    WXRUBY_TRACE_IF(WxRubyTraceAppRun, 1)
      WXRUBY_TRACE("< OnExit")
    WXRUBY_TRACE_END

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
    WXRUBY_TRACE_IF(WxRubyTraceAppRun, 2)
      WXRUBY_TRACE("> _wxRuby_Cleanup")
    WXRUBY_TRACE_END

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

    WXRUBY_TRACE_IF(WxRubyTraceAppRun, 2)
      WXRUBY_TRACE("< _wxRuby_Cleanup")
    WXRUBY_TRACE_END
  }
};
