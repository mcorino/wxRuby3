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
  ~WxRubySharedEvtHandler() = default;

  wxEvtHandler* get_evt_handler() { return this->evt_handler_; }

  VALUE get_rb_shared_evt_handler() { return this->rb_shared_evt_handler_; }
  void set_rb_shared_evt_handler(VALUE h) { this->rb_shared_evt_handler_ = h; }

  WxRubySharedEvtHandler* clone()
  {
    if (this->evt_handler_)
    {
	  WxRubySharedEvtHandler* clone_ = new WxRubySharedEvtHandler(this->evt_handler_);
	  return clone_;
    }
    return nullptr;
  }

private:
  wxEvtHandler* evt_handler_ {};
  VALUE rb_shared_evt_handler_ {Qnil};
};

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

static VALUE WxRuby_get_EvtHandlerClass()
{
  static VALUE cEvtHandler = Qnil;
  if (RB_NIL_P(cEvtHandler))
  {
    cEvtHandler = rb_const_get(wxRuby_Core(), rb_intern("EvtHandler"));
  }
  return cEvtHandler;
}

static VALUE WxRuby_MakeSharedEvtHandler(wxEvtHandler* wxeh)
{
  if (wxeh)
  {
    // create new shared handler
    WxRubySharedEvtHandler* seh = new WxRubySharedEvtHandler(wxeh);
    // create Ruby wrapper object
    VALUE rb_shared_eh =TypedData_Wrap_Struct(cWxRubySharedEvtHandler,
                                              &__WxRubySharedEvtHandler_type,
                                              seh);
    rb_shared_eh = rb_obj_freeze(rb_shared_eh);
    seh->set_rb_shared_evt_handler(rb_shared_eh);
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
    {
      wxEvtHandler* wxeh = shared_eh->get_evt_handler();
      VALUE rb_eh = wxRuby_FindTracking(wxeh);
      if (rb_obj_is_kind_of(rb_eh, WxRuby_get_EvtHandlerClass()))
        return wxeh;
    }
  }
  return nullptr;
}

static VALUE WxRubySharedEvtHandler_clone(VALUE self)
{
  WxRubySharedEvtHandler* shared_eh = (WxRubySharedEvtHandler*)RTYPEDDATA_DATA(self);
  // create new Ruby SharedEvtHandler wrapper object with cloned WxRubySharedEvtHandler
  VALUE clone = TypedData_Wrap_Struct(cWxRubySharedEvtHandler,
                                      &__WxRubySharedEvtHandler_type,
                                      shared_eh->clone());
  return rb_obj_freeze(clone);
}

static VALUE WxRubySharedEvtHandler_queue_event(int argc, VALUE* argv, VALUE self)
{
  // check argument count
  if (argc != 1)
  {
    rb_raise(rb_eArgError, "wrong # of arguments(%d for 1)",argc);
    return Qnil;
  }
  // dereference shared event handler
  wxEvtHandler* wxeh = WxRuby_GetSharedEvtHandler(self);
  if (wxeh)
  {
    // get C++ event
    wxEvent* wxevt = (wxEvent*)DATA_PTR(argv[0]);
    RDATA(argv[0])->dfree = 0; // disown
    DATA_PTR(argv[0]) = nullptr; // unlink
    // no need to remove tracking as all Ractor safe events are untracked
    // queue event
    wxeh->QueueEvent(wxevt);
  }
  else
  {
    rb_raise(rb_eRuntimeError, "Event handler already deleted.");
  }

  return Qnil;
}

static VALUE wxRuby_EvtHandler_make_shared(VALUE self)
{
  void *ptr;
  wxEvtHandler *wxeh = nullptr;
  ptr = DATA_PTR(self);
  wxeh = reinterpret_cast< wxEvtHandler * >(ptr);
  if (wxeh)
  {
    VALUE rb_shared_eh = WxRuby_MakeSharedEvtHandler(wxeh);
    if (RB_NIL_P(rb_shared_eh))  rb_raise(rb_eRuntimeError, "Unable to create shared event handler");
    return rb_shared_eh;
  }
  else
  {
    rb_raise(rb_eRuntimeError, "Object already deleted.");
    return Qnil;
  }
}

static void wx_setup_WxRubySharedEvtHandler(VALUE mWxExt)
{
  // mark thids extension Ractor safe
  rb_ext_ractor_safe(true);

  cWxRubySharedEvtHandler = rb_define_class_under(mWxExt, "SharedEvtHandler", rb_cObject);
  rb_undef_alloc_func(cWxRubySharedEvtHandler);
  rb_define_method(cWxRubySharedEvtHandler, "clone", VALUEFUNC(WxRubySharedEvtHandler_clone), 0);
  rb_define_method(cWxRubySharedEvtHandler, "queue_event", VALUEFUNC(WxRubySharedEvtHandler_queue_event), -1);

  VALUE klass = WxRuby_get_EvtHandlerClass();
  rb_define_method(klass, "make_shared", VALUEFUNC(wxRuby_EvtHandler_make_shared), 0);
}

#endif
