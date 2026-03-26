// Copyright (c) 2023 M.J.N. Corino, The Netherlands
//
// This software is released under the MIT license.

/*
 * WxRuby3 SharedEvtHandler class
 */

#ifndef _WXRUBY_SHARED_EVTHANDLER_H
#define _WXRUBY_SHARED_EVTHANDLER_H

#include <wx/object.h>
#include <wx/event.h>
#include <set>
#include <mutex>

class WxRubySharedEvtHandler
{
public:
  WxRubySharedEvtHandler(wxEvtHandler* evt_handler)
    : evt_handler_(evt_handler) {}
  ~WxRubySharedEvtHandler()
  {
    const std::lock_guard<std::mutex> guard(WxRubyEvtHandlerRef::s_lock_);
    if (this->evt_handler_)
    {
      WxRubyEvtHandlerRef* eh_ref = dynamic_cast<WxRubyEvtHandlerRef*> (this->evt_handler_->GetRefData());
      if (eh_ref) eh_ref->_remove_shared_handler(this);
    }
  }

  wxEvtHandler* get_evt_handler()
  {
    const std::lock_guard<std::mutex> guard(WxRubyEvtHandlerRef::s_lock_);
    return this->evt_handler_;
  }

  VALUE get_rb_shared_evt_handler() { return this->rb_shared_evt_handler_; }
  void set_rb_shared_evt_handler(VALUE h) { this->rb_shared_evt_handler_ = h; }

  WxRubySharedEvtHandler* clone()
  {
    const std::lock_guard<std::mutex> guard(WxRubyEvtHandlerRef::s_lock_);
    if (this->evt_handler_)
    {
      WxRubyEvtHandlerRef* eh_ref = dynamic_cast<WxRubyEvtHandlerRef*> (this->evt_handler_->GetRefData());
      if (eh_ref)
      {
        WxRubySharedEvtHandler* clone_ = new WxRubySharedEvtHandler(this->evt_handler_);
        eh_ref->_add_shared_handler(clone_);
        return clone_;
      }
    }
    return nullptr;
  }

private:
  friend class WxRubyEvtHandlerRef;

  void reset_evt_handler() { this->evt_handler_ = nullptr; }

  wxEvtHandler* evt_handler_ {};
  VALUE rb_shared_evt_handler_ {Qnil};
};

class WxRubyEvtHandlerRef : public wxObjectRefData
{
public:
  WxRubyEvtHandlerRef() {}
  ~WxRubyEvtHandlerRef()
  {
    const std::lock_guard<std::mutex> guard(s_lock_);
    for (WxRubySharedEvtHandler* seh : this->shared_handlers_)
      seh->reset_evt_handler();
  }

  void add_shared_handler(WxRubySharedEvtHandler* seh)
  {
    const std::lock_guard<std::mutex> guard(s_lock_);
    this->_add_shared_handler(seh);
  }

private:
  friend class WxRubySharedEvtHandler;

  void _add_shared_handler(WxRubySharedEvtHandler* seh)
  {
    this->shared_handlers_.emplace(seh);
  }

  void _remove_shared_handler(WxRubySharedEvtHandler* seh)
  {
    this->shared_handlers_.erase(seh)
  }

  typedef std::set<WxRubySharedEvtHandler*> shared_handler_list_t;
  shared_handler_list_t shared_handlers_ {};

public:
  static std::mutex s_lock_;
};

std::mutex WxRubyEvtHandlerRef:s_lock_ {};

// WxRubySharedEvtHandler wrapper class definition and helper functions
static size_t __WxRubySharedEvtHandler_size(const void* data)
{
  return 0;
}

static void __WxRubySharedEvtHandler_free(void* data)
{
  if (data)
    delete (WxRubySharedEvtHandler*)data;
}

#include <ruby/version.h>

static const rb_data_type_t __WxRubySharedEvtHandler_type = {
  "TreeItemId",
#if RUBY_API_VERSION_MAJOR >= 3
  { NULL, __WxRubySharedEvtHandler_free, __WxRubySharedEvtHandler_size, 0, {}},
#else
  { NULL, __WxRubySharedEvtHandler_free, __WxRubySharedEvtHandler_size, {}},
#endif
  NULL, NULL, RUBY_TYPED_FROZEN_SHAREABLE
};

VALUE cWxRubySharedEvtHandler;

static VALUE WxRuby_MakeSharedEvtHandler(wxEvtHandler* wxeh)
{
  if (wxeh)
  {
    WxRubyEvtHandlerRef* eh_ref = nullptr;
    if (wxeh->GetRefData())
    {
      eh_ref = dynamic_cast<WxRubyEvtHandlerRef*> (wxeh->GetRefData());
      if (!eh_ref)  // should never happen in wxRuby3
      {
        std::wcerr << "ERROR: Cannot make shared EvtHandler. wxEvtHandler already has RefData set." << std::endl;
        return Qnil;
      }
    }
    else
    {
      eh_ref = new WxRubyEvtHandlerRef(wxeh);
      wxeh->SetRefData(eh_ref);
    }

    // create new shared handler
    WxRubySharedEvtHandler* seh = new WxRubySharedEvtHandler(weh);
    // create Ruby wrapper object
    VALUE rb_shared_eh =TypedData_Wrap_Struct(cWxRubySharedEvtHandler,
                                              &__WxRubySharedEvtHandler_type,
                                              &seh);
    rb_shared_eh = rb_obj_freeze(rb_shared_eh);
    seh->set_rb_shared_evt_handler(rb_shared_eh);
    // register shared handler
    eh_ref->add_shared_handler(seh);

    return rb_shared_eh;
  }

  return Qnil;
}

static wxEvtHandler* WxRuby_GetSharedEvtHandler(VALUE rb_shared_eh)
{
  if (rb_typeddata_is_kind_of(rb_shared_eh, &__WxRubySharedEvtHandler_type) == 1)
  {
    WxRubySharedEvtHandler* shared_eh = (WxRubySharedEvtHandler*)RTYPEDDATA_DATA(rb_shared_eh);
    if (shared_eh)
      return shared_eh->get_evt_handler();
  }
  return nullptr;
}

static VALUE WxRubySharedEvtHandler_clone(VALUE self)
{
  WxRubySharedEvtHandler* shared_eh = (WxRubySharedEvtHandler*)RTYPEDDATA_DATA(self);
  VALUE clone = rb_obj_clone(self);
  RTYPEDDATA_DATA(clone) = (void*)shared_eh->clone();
  return clone;
}

static VALUE WxRubySharedEvtHandler_queue_event(int argc, VALUE* argv, VALUE self)
{
  // check argument count
  if (argc != 1)
  {
    rb_raise(rb_eArgError, "wrong # of arguments(%d for 1)",argc);
    return Qnil;
  }
  // derefence shared event handler
  wxEvtHandler* wxeh = WxRuby_GetSharedEvtHandler(self);
  // get C++ event
  wxEvent* wxevt = (wxEvent*)DATA_PTR(argv[0]);
  // unlink and remove tracking for any event (only C++ state left)
  SWIG_RubyUnlinkObjects((void*)arg2);
  wxRuby_RemoveTracking((void*)arg2);
  // queue event
  wxeh->QueueEvent(wxevt);

  return Qnil;
}

static VALUE wxRuby_EvtHandler_make_shared(VALUE self)
{
  void *ptr;
  wxEvtHandler *wxeh = nullptr;
  swig_type_info* swig_type = wxRuby_GetSwigTypeForClass(CLASS_OF(self));
  int res = SWIG_ConvertPtr(self, &ptr, SWIGTYPE_p_wxEvtHandler, 0);
  if (!SWIG_IsOK(res))
  {
    rb_raise(rb_eTypeError, "Expected self to be EvtHandler");
    return Qnil;
  }
  wxeh = reinterpret_cast< wxEvtHandler * >(ptr);

  VALUE rb_shared_eh = WxRuby_MakeSharedEvtHandler(wxeh);
  if (RB_NIL_P(rb_shared_eh))  rb_raise(rb_eRuntimeError, "Unable to create shared event handler");
  return rb_shared_eh;
}

static void wx_setup_WxRubySharedEvtHandler()
{
  // mark thids extension Ractor safe
  rb_ext_ractor_safe(true);

  cWxRubySharedEvtHandler = rb_define_class_under(mWxCore, "SharedEvtHandler", rb_cObject);
  rb_undef_alloc_func(cWxRubySharedEvtHandler);
  rb_define_method(cWxRubySharedEvtHandler, "clone", VALUEFUNC(WxRubySharedEvtHandler_clone), 0);
  rb_define_method(cWxRubySharedEvtHandler, "queue_event", VALUEFUNC(WxRubySharedEvtHandler_queue_event), -1);
}

#endif
