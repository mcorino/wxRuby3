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

class WxRubySharedEvtHandler
{
public:
  WxRubySharedEvtHandler(wxEvtHandler* evt_handler)
    : evt_handler_(evt_handler) {}
  ~WxRubySharedEvtHandler()
  {
    // unlink
    if (!RB_NIL_P(this->rb_shared_evt_handler_))
      RTYPEDDATA(this->rb_shared_evt_handler_)->data = nullptr;
  }

  wxEvtHandler* get_evt_handler() { return this->evt_handler_; }

  VALUE get_rb_shared_evt_handler() { return this->rb_shared_evt_handler_; }
  void set_rb_shared_evt_handler(VALUE h) { this->rb_shared_evt_handler_ = h; }

private:
  wxEvtHandler* evt_handler_ {};
  VALUE rb_shared_evt_handler_ {Qnil};
};

class WxRubyEvtHandlerRef : public wxObjectRefData
{
public:
  WxRubyEvtHandlerRef(wxEvtHandler* evt_handler)
    : shared_handler_(evt_handler) {}

  WxRubySharedEvtHandler& get_shared_handler() { return this->shared_handler_; }

private:
  WxRubySharedEvtHandler shared_handler_;
};

// WxRubySharedEvtHandler wrapper class definition and helper functions
static size_t __WxRubySharedEvtHandler_size(const void* data)
{
  return 0;
}

#include <ruby/version.h>

static const rb_data_type_t __WxRubySharedEvtHandler_type = {
  "TreeItemId",
#if RUBY_API_VERSION_MAJOR >= 3
  { NULL, NULL, __WxRubySharedEvtHandler_size, 0, {}},
#else
  { NULL, NULL, __WxRubySharedEvtHandler_size, {}},
#endif
  NULL, NULL, RUBY_TYPED_FROZEN_SHAREABLE
};

VALUE cWxRubySharedEvtHandler;

static VALUE WxRuby_MakeSharedEvtHandler(wxEvtHandler* wxeh)
{
  if (wxeh && wxeh->GetRefData())
  {
    WxRubyEvtHandlerRef* eh_ref = dynamic_cast<WxRubyEvtHandlerRef*> (wxeh->GetRefData());
    if (eh_ref)
    {
      return eh_ref->get_shared_handler().get_rb_shared_evt_handler();
    }
    else // should never happen in wxRuby3
    {
      std::wcerr << "ERROR: Cannot make shared EvtHandler. wxEvtHandler already has RefData set." << std::endl;
    }
  }
  else if (wxeh)
  {
    WxRubyEvtHandlerRef* eh_ref = new WxRubyEvtHandlerRef(wxeh);
    VALUE rb_shared_eh =TypedData_Wrap_Struct(cWxRubySharedEvtHandler,
                                              &__WxRubySharedEvtHandler_type,
                                              &eh_ref->get_shared_handler());
    rb_shared_eh = rb_obj_freeze(rb_shared_eh);
    eh_ref->get_shared_handler().set_rb_shared_evt_handler(rb_shared_eh);
    wxeh->SetRefData(eh_ref);
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
    RTYPEDDATA_DATA(clone) = (void*)shared_eh;
    return clone;
}

static VALUE WxRubySharedEvtHandler_queue_event(int argc, VALUE* argv, VALUE self)
{
  return Qnil;
}

static VALUE WxRubySharedEvtHandler_call_after(int argc, VALUE* argv, VALUE self)
{
  return Qnil;
}

static void wx_setup_WxRubySharedEvtHandler()
{
  rb_ext_ractor_safe(true);

  cWxRubySharedEvtHandler = rb_define_class_under(mWxCore, "SharedEvtHandler", rb_cObject);
  rb_undef_alloc_func(cWxRubySharedEvtHandler);
  rb_define_method(cWxRubySharedEvtHandler, "clone", VALUEFUNC(WxRubySharedEvtHandler_clone), 0);
  rb_define_method(cWxRubySharedEvtHandler, "call_after", VALUEFUNC(WxRubySharedEvtHandler_call_after), -1);
  rb_define_method(cWxRubySharedEvtHandler, "queue_event", VALUEFUNC(WxRubySharedEvtHandler_queue_event), -1);
}

#endif
