// Copyright (c) 2023 M.J.N. Corino, The Netherlands
//
// This software is released under the MIT license.

/*
 * WxRuby3 WxRubyComboPopup class
 */

#ifndef _WXRUBY_COMBO_POPUP_H
#define _WXRUBY_COMBO_POPUP_H

#include <wx/combo.h>
#include <map>

class WxRubyComboPopup : public wxComboPopup
{
private:
  static WxRuby_ID init_ID;
  static WxRuby_ID lazy_create_ID;
  static WxRuby_ID create_ID;
  static WxRuby_ID destroy_popup_ID;
  static WxRuby_ID find_item_ID;
  static WxRuby_ID get_adjusted_size_ID;
  static WxRuby_ID get_control_ID;
  static WxRuby_ID set_string_value_ID;
  static WxRuby_ID get_string_value_ID;
  static WxRuby_ID on_combo_double_click_ID;
  static WxRuby_ID on_combo_key_event_ID;
  static WxRuby_ID on_combo_char_event_ID;
  static WxRuby_ID on_dismiss_ID;
  static WxRuby_ID on_popup_ID;
  static WxRuby_ID paint_combo_control_ID;

  static std::map<WxRubyComboPopup*, VALUE> combo_popup_map;

  VALUE rb_combo_popup_;

  class Exception : public Swig::DirectorException
  {
  public:
    Exception(VALUE error, const char *hdr, const char *msg ="")
     : Swig::DirectorException(error, hdr, msg)
    {}
  };

public:
  static void GC_mark_combo_popups()
  {
    for (auto pair : combo_popup_map)
    {
      rb_gc_mark(pair.second);
    }
  }

  WxRubyComboPopup(VALUE rb_cp)
    : wxComboPopup()
    , rb_combo_popup_(rb_cp)
  {
    combo_popup_map[this] = rb_cp; // register
  }

  virtual ~WxRubyComboPopup()
  {
    if (!NIL_P(rb_combo_popup_))
    {
      combo_popup_map.erase(this); //deregister
      // unlink
      rb_iv_set(rb_combo_popup_, "@_wx_combo_popup_proxy", Qnil);
      rb_combo_popup_ = Qnil;
    }
  }

  VALUE GetRubyComboPopup() const
  {
    return rb_combo_popup_;
  }

  virtual void Init() override
  {
    wxRuby_Funcall(rb_combo_popup_, init_ID(), 0);
  }

  virtual bool LazyCreate() override
  {
    VALUE rc = wxRuby_Funcall(rb_combo_popup_, lazy_create_ID(), 0);
    return rc == Qtrue ? true : false;
  }

  virtual bool Create(wxWindow* parent) override
  {
    VALUE rb_parent = wxRuby_WrapWxObjectInRuby(parent);
    VALUE rc = wxRuby_Funcall(rb_combo_popup_, create_ID(), 1, rb_parent);
    return rc == Qtrue ? true : false;
  }

  virtual void DestroyPopup() override
  {
    wxRuby_Funcall(rb_combo_popup_, destroy_popup_ID(), 0);
    delete this;
  }

  virtual bool FindItem(const wxString& item, wxString* trueItem=nullptr) override
  {
    VALUE rc = wxRuby_Funcall(rb_combo_popup_, find_item_ID(), 2, WXSTR_TO_RSTR(item), trueItem ? Qtrue : Qfalse);
    if (TYPE(rc) == T_STRING && trueItem)
    {
      *trueItem = RSTR_TO_WXSTR(rc);
      return true;
    }
    return (rc == Qfalse || NIL_P(rc)) ? false : true;
  }

  virtual wxSize GetAdjustedSize(int minWidth, int prefHeight, int maxHeight) override
  {
    VALUE rc = wxRuby_Funcall(rb_combo_popup_, get_adjusted_size_ID(),
                              3, INT2NUM(minWidth), INT2NUM(prefHeight), INT2NUM(maxHeight));
    if (TYPE(rc) == T_DATA)
    {
      void* ptr;
      SWIG_ConvertPtr(rc, &ptr, SWIGTYPE_p_wxSize, 0);
      return *reinterpret_cast<wxSize * >(ptr);
    }
    else if (TYPE(rc) == T_ARRAY && RARRAY_LEN(rc) == 2)
    {
      return wxSize(NUM2INT(rb_ary_entry(rc, 0)), NUM2INT(rb_ary_entry(rc, 1)));
    }
    else
    {
      throw Exception(rb_eTypeError, "Return type error: ",
                              "expected Wx::Size or Array(Integer,Integer) from #get_adjusted_size");
    }
  }

  virtual wxWindow *GetControl() override
  {
    VALUE rc = wxRuby_Funcall(rb_combo_popup_, get_control_ID(), 0);
    void *ptr;
    int res = SWIG_ConvertPtr(rc, &ptr, SWIGTYPE_p_wxWindow, 0);
    if (!SWIG_IsOK(res))
    {
      throw Exception(rb_eTypeError, "Return type error: ",
                              "expected Wx::Window from #get_control");
    }
    return reinterpret_cast<wxWindow*>(ptr);
  }

  virtual void SetStringValue(const wxString& value) override
  {
    wxRuby_Funcall(rb_combo_popup_, set_string_value_ID(), 1, WXSTR_TO_RSTR(value));
  }

  virtual wxString GetStringValue() const override
  {
    VALUE rc = wxRuby_Funcall(rb_combo_popup_, get_string_value_ID(), 0);
    return RSTR_TO_WXSTR(rc);
  }

  virtual void OnComboKeyEvent(wxKeyEvent& event) override
  {
#if __WXRB_DEBUG__
    wxRuby_Funcall(rb_combo_popup_, on_combo_key_event_ID(), 1, wxRuby_WrapWxEventInRuby(nullptr, &event));
#else
    wxRuby_Funcall(rb_combo_popup_, on_combo_key_event_ID(), 1, wxRuby_WrapWxEventInRuby(&event));
#endif
  }

  virtual void OnComboCharEvent(wxKeyEvent& event) override
  {
#if __WXRB_DEBUG__
    wxRuby_Funcall(rb_combo_popup_, on_combo_char_event_ID(), 1, wxRuby_WrapWxEventInRuby(nullptr, &event));
#else
    wxRuby_Funcall(rb_combo_popup_, on_combo_char_event_ID(), 1, wxRuby_WrapWxEventInRuby(&event));
#endif
  }

  virtual void OnComboDoubleClick() override
  {
    wxRuby_Funcall(rb_combo_popup_, on_combo_double_click_ID(), 0);
  }

  virtual void OnPopup() override
  {
    wxRuby_Funcall(rb_combo_popup_, on_popup_ID(), 0);
  }

  virtual void OnDismiss() override
  {
    wxRuby_Funcall(rb_combo_popup_, on_dismiss_ID(), 0);
  }

  virtual void PaintComboControl(wxDC& dc, const wxRect& rect) override
  {
    wxRuby_Funcall(rb_combo_popup_, paint_combo_control_ID(), 2,
                   SWIG_NewPointerObj(SWIG_as_voidptr(&dc), SWIGTYPE_p_wxDC,  0),
                   SWIG_NewPointerObj(new wxRect(rect), SWIGTYPE_p_wxRect, SWIG_POINTER_OWN));
  }

};

WxRuby_ID WxRubyComboPopup::init_ID("init");
WxRuby_ID WxRubyComboPopup::lazy_create_ID("lazy_create");
WxRuby_ID WxRubyComboPopup::create_ID("create");
WxRuby_ID WxRubyComboPopup::destroy_popup_ID("destroy_popup");
WxRuby_ID WxRubyComboPopup::find_item_ID("find_item");
WxRuby_ID WxRubyComboPopup::get_adjusted_size_ID("get_adjusted_size");
WxRuby_ID WxRubyComboPopup::get_control_ID("get_control");
WxRuby_ID WxRubyComboPopup::set_string_value_ID("set_string_value");
WxRuby_ID WxRubyComboPopup::get_string_value_ID("get_string_value");
WxRuby_ID WxRubyComboPopup::on_combo_double_click_ID("on_combo_double_click");
WxRuby_ID WxRubyComboPopup::on_combo_key_event_ID("on_combo_key_event");
WxRuby_ID WxRubyComboPopup::on_combo_char_event_ID("on_combo_char_event");
WxRuby_ID WxRubyComboPopup::on_dismiss_ID("on_dismiss");
WxRuby_ID WxRubyComboPopup::on_popup_ID("on_popup");
WxRuby_ID WxRubyComboPopup::paint_combo_control_ID("paint_combo_control");

std::map<WxRubyComboPopup*, VALUE> WxRubyComboPopup::combo_popup_map;

// Wrapper methods for module Wx::ComboPopup

static VALUE wx_combo_popup_get_combo_ctrl(int argc, VALUE *argv, VALUE self)
{
  if (argc < 0 || argc > 0)
  {
    rb_raise(rb_eArgError, "wrong # of arguments (%d for 0)", argc);
  }

  VALUE rb_cp_proxy = rb_iv_get(self, "@_wx_combo_popup_proxy");
  if (!NIL_P(rb_cp_proxy))
  {
    wxComboPopup* cpp = nullptr;
    Data_Get_Struct(rb_cp_proxy, wxComboPopup, cpp);
    if (cpp)
    {
      try {
        wxComboCtrl* combo = cpp->GetComboCtrl();
        return wxRuby_WrapWxObjectInRuby(combo);
      }
      catch (const Swig::DirectorException& swigex) {
        if (rb_obj_is_kind_of(swigex.getError(), rb_eException))
        {
          rb_exc_raise(swigex.getError());
        }
        else
        {
          rb_exc_raise(rb_exc_new_cstr(swigex.getError(), swigex.what()));
        }
      }
      catch (const std::exception& ex) {
        rb_raise(rb_eRuntimeError, "Unexpected C++ exception: %s", ex.what());
      }
      catch (...) {
        rb_raise(rb_eRuntimeError, "Unexpected UNKNOWN exception");
      }
    }
  }
  return Qnil;
}

// Wrapper methods for class Wx::ComboPopupWx

static VALUE combo_popup_wx_get_combo_ctrl(int argc, VALUE *argv, VALUE self)
{
  wxComboPopup *cpp;
  Data_Get_Struct(self, wxComboPopup, cpp);

  if (argc < 0 || argc > 0)
  {
    rb_raise(rb_eArgError, "wrong # of arguments (%d for 0)", argc);
  }

  try {
    wxComboCtrl* combo = cpp->GetComboCtrl();
    return wxRuby_WrapWxObjectInRuby(combo);
  }
  catch (const Swig::DirectorException& swigex) {
    if (rb_obj_is_kind_of(swigex.getError(), rb_eException))
    {
      rb_exc_raise(swigex.getError());
    }
    else
    {
      rb_exc_raise(rb_exc_new_cstr(swigex.getError(), swigex.what()));
    }
  }
  catch (const std::exception& ex) {
    rb_raise(rb_eRuntimeError, "Unexpected C++ exception: %s", ex.what());
  }
  catch (...) {
    rb_raise(rb_eRuntimeError, "Unexpected UNKNOWN exception");
  }
}

static VALUE combo_popup_wx_lazy_create(int argc, VALUE *argv, VALUE self)
{
  wxComboPopup *cpp;
  Data_Get_Struct(self, wxComboPopup, cpp);

  if (argc < 0 || argc > 0)
  {
    rb_raise(rb_eArgError, "wrong # of arguments (%d for 0)", argc);
  }

  try {
    return cpp->LazyCreate() ? Qtrue : Qfalse;
  }
  catch (const Swig::DirectorException& swigex) {
    if (rb_obj_is_kind_of(swigex.getError(), rb_eException))
    {
      rb_exc_raise(swigex.getError());
    }
    else
    {
      rb_exc_raise(rb_exc_new_cstr(swigex.getError(), swigex.what()));
    }
  }
  catch (const std::exception& ex) {
    rb_raise(rb_eRuntimeError, "Unexpected C++ exception: %s", ex.what());
  }
  catch (...) {
    rb_raise(rb_eRuntimeError, "Unexpected UNKNOWN exception");
  }
}

static VALUE combo_popup_wx_create(int argc, VALUE *argv, VALUE self)
{
  wxComboPopup *cpp;
  Data_Get_Struct(self, wxComboPopup, cpp);

  if (argc < 1 || argc > 1)
  {
    rb_raise(rb_eArgError, "wrong # of arguments (%d for 1)", argc);
  }

  void *ptr;
  int res = SWIG_ConvertPtr(argv[0], &ptr, SWIGTYPE_p_wxWindow,  0);
  if (!SWIG_IsOK(res)) {
    rb_raise(rb_eArgError, "Expected Wx::Window for 1");
    return Qnil;
  }
  wxWindow *parent = reinterpret_cast< wxWindow * >(ptr);
  if (!parent)
  {
    rb_raise(rb_eArgError,
             "Window parent argument must not be nil");
  }

  try {
    return cpp->Create(parent) ? Qtrue : Qfalse;
  }
  catch (const Swig::DirectorException& swigex) {
    if (rb_obj_is_kind_of(swigex.getError(), rb_eException))
    {
      rb_exc_raise(swigex.getError());
    }
    else
    {
      rb_exc_raise(rb_exc_new_cstr(swigex.getError(), swigex.what()));
    }
  }
  catch (const std::exception& ex) {
    rb_raise(rb_eRuntimeError, "Unexpected C++ exception: %s", ex.what());
  }
  catch (...) {
    rb_raise(rb_eRuntimeError, "Unexpected UNKNOWN exception");
  }
}

static VALUE combo_popup_wx_find_item(int argc, VALUE *argv, VALUE self)
{
  wxComboPopup *cpp;
  Data_Get_Struct(self, wxComboPopup, cpp);

  if (argc < 1 || argc > 2)
  {
    rb_raise(rb_eArgError, "wrong # of arguments (%d for 2)", argc);
  }

  wxString item = RSTR_TO_WXSTR(argv[0]);
  bool f_trueItem = (argc<2 || (argv[1] == Qfalse || argv[1] == Qnil)) ? false : true;
  wxString trueItem;
  try {
    bool rc = cpp->FindItem(item, f_trueItem ? &trueItem : nullptr);
    return rc ? (f_trueItem ? WXSTR_TO_RSTR(trueItem) : Qtrue) : Qfalse;
  }
  catch (const Swig::DirectorException& swigex) {
    if (rb_obj_is_kind_of(swigex.getError(), rb_eException))
    {
      rb_exc_raise(swigex.getError());
    }
    else
    {
      rb_exc_raise(rb_exc_new_cstr(swigex.getError(), swigex.what()));
    }
  }
  catch (const std::exception& ex) {
    rb_raise(rb_eRuntimeError, "Unexpected C++ exception: %s", ex.what());
  }
  catch (...) {
    rb_raise(rb_eRuntimeError, "Unexpected UNKNOWN exception");
  }
}

static VALUE combo_popup_wx_get_adjusted_size(int argc, VALUE *argv, VALUE self)
{
  wxComboPopup *cpp;
  Data_Get_Struct(self, wxComboPopup, cpp);

  if (argc < 3 || argc > 3)
  {
    rb_raise(rb_eArgError, "wrong # of arguments (%d for 3)", argc);
  }

  try {
    wxSize sz = cpp->GetAdjustedSize(NUM2INT(argv[0]), NUM2INT(argv[1]), NUM2INT(argv[2]));
    return SWIG_NewPointerObj(new wxSize(sz), SWIGTYPE_p_wxSize, SWIG_POINTER_OWN);
  }
  catch (const Swig::DirectorException& swigex) {
    if (rb_obj_is_kind_of(swigex.getError(), rb_eException))
    {
      rb_exc_raise(swigex.getError());
    }
    else
    {
      rb_exc_raise(rb_exc_new_cstr(swigex.getError(), swigex.what()));
    }
  }
  catch (const std::exception& ex) {
    rb_raise(rb_eRuntimeError, "Unexpected C++ exception: %s", ex.what());
  }
  catch (...) {
    rb_raise(rb_eRuntimeError, "Unexpected UNKNOWN exception");
  }
}

static VALUE combo_popup_wx_get_control(int argc, VALUE *argv, VALUE self)
{
  wxComboPopup *cpp;
  Data_Get_Struct(self, wxComboPopup, cpp);

  if (argc < 0 || argc > 0)
  {
    rb_raise(rb_eArgError, "wrong # of arguments (%d for 0)", argc);
  }

  try {
    wxWindow* control = cpp->GetControl();
    return wxRuby_WrapWxObjectInRuby(control);
  }
  catch (const Swig::DirectorException& swigex) {
    if (rb_obj_is_kind_of(swigex.getError(), rb_eException))
    {
      rb_exc_raise(swigex.getError());
    }
    else
    {
      rb_exc_raise(rb_exc_new_cstr(swigex.getError(), swigex.what()));
    }
  }
  catch (const std::exception& ex) {
    rb_raise(rb_eRuntimeError, "Unexpected C++ exception: %s", ex.what());
  }
  catch (...) {
    rb_raise(rb_eRuntimeError, "Unexpected UNKNOWN exception");
  }
}

static VALUE combo_popup_wx_set_string_value(int argc, VALUE *argv, VALUE self)
{
  wxComboPopup *cpp;
  Data_Get_Struct(self, wxComboPopup, cpp);

  if (argc < 1 || argc > 1)
  {
    rb_raise(rb_eArgError, "wrong # of arguments (%d for 1)", argc);
  }

  try {
    wxString val = RSTR_TO_WXSTR(argv[0]);
    cpp->SetStringValue(val);
    return Qnil;
  }
  catch (const Swig::DirectorException& swigex) {
    if (rb_obj_is_kind_of(swigex.getError(), rb_eException))
    {
      rb_exc_raise(swigex.getError());
    }
    else
    {
      rb_exc_raise(rb_exc_new_cstr(swigex.getError(), swigex.what()));
    }
  }
  catch (const std::exception& ex) {
    rb_raise(rb_eRuntimeError, "Unexpected C++ exception: %s", ex.what());
  }
  catch (...) {
    rb_raise(rb_eRuntimeError, "Unexpected UNKNOWN exception");
  }
}

static VALUE combo_popup_wx_get_string_value(int argc, VALUE *argv, VALUE self)
{
  wxComboPopup *cpp;
  Data_Get_Struct(self, wxComboPopup, cpp);

  if (argc < 0 || argc > 0)
  {
    rb_raise(rb_eArgError, "wrong # of arguments (%d for 0)", argc);
  }

  try {
    wxString val = cpp->GetStringValue();
    return WXSTR_TO_RSTR(val);
  }
  catch (const Swig::DirectorException& swigex) {
    if (rb_obj_is_kind_of(swigex.getError(), rb_eException))
    {
      rb_exc_raise(swigex.getError());
    }
    else
    {
      rb_exc_raise(rb_exc_new_cstr(swigex.getError(), swigex.what()));
    }
  }
  catch (const std::exception& ex) {
    rb_raise(rb_eRuntimeError, "Unexpected C++ exception: %s", ex.what());
  }
  catch (...) {
    rb_raise(rb_eRuntimeError, "Unexpected UNKNOWN exception");
  }
}

static VALUE combo_popup_wx_on_combo_double_click(int argc, VALUE *argv, VALUE self)
{
  wxComboPopup *cpp;
  Data_Get_Struct(self, wxComboPopup, cpp);

  if (argc < 0 || argc > 0)
  {
    rb_raise(rb_eArgError, "wrong # of arguments (%d for 0)", argc);
  }

  try {
    cpp->OnComboDoubleClick();
  }
  catch (const Swig::DirectorException& swigex) {
    if (rb_obj_is_kind_of(swigex.getError(), rb_eException))
    {
      rb_exc_raise(swigex.getError());
    }
    else
    {
      rb_exc_raise(rb_exc_new_cstr(swigex.getError(), swigex.what()));
    }
  }
  catch (const std::exception& ex) {
    rb_raise(rb_eRuntimeError, "Unexpected C++ exception: %s", ex.what());
  }
  catch (...) {
    rb_raise(rb_eRuntimeError, "Unexpected UNKNOWN exception");
  }
  return Qnil;
}

static VALUE get_key_event_class()
{
  static VALUE key_event_klass = Qnil;
  if (NIL_P(key_event_klass))
  {
    key_event_klass = rb_eval_string("Wx::KeyEvent");
  }
  return key_event_klass;
}

static VALUE combo_popup_wx_on_combo_key_event(int argc, VALUE *argv, VALUE self)
{
  wxComboPopup *cpp;
  Data_Get_Struct(self, wxComboPopup, cpp);

  if (argc < 1 || argc > 1)
  {
    rb_raise(rb_eArgError, "wrong # of arguments (%d for 1)", argc);
  }

  if (!rb_obj_is_kind_of(argv[0], get_key_event_class()))
  {
    rb_raise(rb_eTypeError, "Expected Wx::KeyEvent for 1");
  }

  wxEvent* evt = reinterpret_cast<wxEvent*> (DATA_PTR(argv[0]));
  if (evt == nullptr)
  {
    rb_raise(rb_eTypeError, "Invalid null reference for Wx::KeyEvent");
  }

  try {
    cpp->OnComboKeyEvent(*dynamic_cast<wxKeyEvent*> (evt));
  }
  catch (const Swig::DirectorException& swigex) {
    if (rb_obj_is_kind_of(swigex.getError(), rb_eException))
    {
      rb_exc_raise(swigex.getError());
    }
    else
    {
      rb_exc_raise(rb_exc_new_cstr(swigex.getError(), swigex.what()));
    }
  }
  catch (const std::exception& ex) {
    rb_raise(rb_eRuntimeError, "Unexpected C++ exception: %s", ex.what());
  }
  catch (...) {
    rb_raise(rb_eRuntimeError, "Unexpected UNKNOWN exception");
  }
  return Qnil;
}

static VALUE combo_popup_wx_on_combo_char_event(int argc, VALUE *argv, VALUE self)
{
  wxComboPopup *cpp;
  Data_Get_Struct(self, wxComboPopup, cpp);

  if (argc < 1 || argc > 1)
  {
    rb_raise(rb_eArgError, "wrong # of arguments (%d for 1)", argc);
  }

  if (!rb_obj_is_kind_of(argv[0], get_key_event_class()))
  {
    rb_raise(rb_eTypeError, "Expected Wx::KeyEvent for 1");
  }

  wxEvent* evt = reinterpret_cast<wxEvent*> (DATA_PTR(argv[0]));
  if (evt == nullptr)
  {
    rb_raise(rb_eTypeError, "Invalid null reference for Wx::KeyEvent");
  }

  try {
    cpp->OnComboCharEvent(*dynamic_cast<wxKeyEvent*> (evt));
  }
  catch (const Swig::DirectorException& swigex) {
    if (rb_obj_is_kind_of(swigex.getError(), rb_eException))
    {
      rb_exc_raise(swigex.getError());
    }
    else
    {
      rb_exc_raise(rb_exc_new_cstr(swigex.getError(), swigex.what()));
    }
  }
  catch (const std::exception& ex) {
    rb_raise(rb_eRuntimeError, "Unexpected C++ exception: %s", ex.what());
  }
  catch (...) {
    rb_raise(rb_eRuntimeError, "Unexpected UNKNOWN exception");
  }
  return Qnil;
}

static VALUE combo_popup_wx_on_dismiss(int argc, VALUE *argv, VALUE self)
{
  wxComboPopup *cpp;
  Data_Get_Struct(self, wxComboPopup, cpp);

  if (argc < 0 || argc > 0)
  {
    rb_raise(rb_eArgError, "wrong # of arguments (%d for 0)", argc);
  }

  try {
    cpp->OnDismiss();
  }
  catch (const Swig::DirectorException& swigex) {
    if (rb_obj_is_kind_of(swigex.getError(), rb_eException))
    {
      rb_exc_raise(swigex.getError());
    }
    else
    {
      rb_exc_raise(rb_exc_new_cstr(swigex.getError(), swigex.what()));
    }
  }
  catch (const std::exception& ex) {
    rb_raise(rb_eRuntimeError, "Unexpected C++ exception: %s", ex.what());
  }
  catch (...) {
    rb_raise(rb_eRuntimeError, "Unexpected UNKNOWN exception");
  }
  return Qnil;
}

static VALUE combo_popup_wx_on_popup(int argc, VALUE *argv, VALUE self)
{
  wxComboPopup *cpp;
  Data_Get_Struct(self, wxComboPopup, cpp);

  if (argc < 0 || argc > 0)
  {
    rb_raise(rb_eArgError, "wrong # of arguments (%d for 0)", argc);
  }

  try {
    cpp->OnPopup();
  }
  catch (const Swig::DirectorException& swigex) {
    if (rb_obj_is_kind_of(swigex.getError(), rb_eException))
    {
      rb_exc_raise(swigex.getError());
    }
    else
    {
      rb_exc_raise(rb_exc_new_cstr(swigex.getError(), swigex.what()));
    }
  }
  catch (const std::exception& ex) {
    rb_raise(rb_eRuntimeError, "Unexpected C++ exception: %s", ex.what());
  }
  catch (...) {
    rb_raise(rb_eRuntimeError, "Unexpected UNKNOWN exception");
  }
  return Qnil;
}

static VALUE combo_popup_wx_paint_combo_control(int argc, VALUE *argv, VALUE self)
{
  wxComboPopup *cpp;
  Data_Get_Struct(self, wxComboPopup, cpp);

  if (argc < 2 || argc > 2)
  {
    rb_raise(rb_eArgError, "wrong # of arguments (%d for 2)", argc);
  }

  void *ptr;
  int res = SWIG_ConvertPtr(argv[0], &ptr, SWIGTYPE_p_wxDC,  0);
  if (!SWIG_IsOK(res)) {
    rb_raise(rb_eArgError, "Expected Wx::DC for 1");
    return Qnil;
  }
  if (!ptr) {
    rb_raise(rb_eArgError, "Invalid null reference for Wx::DC");
    return Qnil;
  }
  wxDC *dc = reinterpret_cast< wxDC * >(ptr);
  res = SWIG_ConvertPtr(argv[1], &ptr, SWIGTYPE_p_wxRect,  0);
  if (!SWIG_IsOK(res)) {
    rb_raise(rb_eArgError, "Expected Wx::Rect for 2");
    return Qnil;
  }
  if (!ptr) {
    rb_raise(rb_eArgError, "Invalid null reference for Wx::Rect");
    return Qnil;
  }
  wxRect* rect = reinterpret_cast< wxRect * >(ptr);
  try {
    cpp->PaintComboControl(*dc, *rect);
  }
  catch (const Swig::DirectorException& swigex) {
    if (rb_obj_is_kind_of(swigex.getError(), rb_eException))
    {
      rb_exc_raise(swigex.getError());
    }
    else
    {
      rb_exc_raise(rb_exc_new_cstr(swigex.getError(), swigex.what()));
    }
  }
  catch (const std::exception& ex) {
    rb_raise(rb_eRuntimeError, "Unexpected C++ exception: %s", ex.what());
  }
  catch (...) {
    rb_raise(rb_eRuntimeError, "Unexpected UNKNOWN exception");
  }
  return Qnil;
}

#endif /* _WXRUBY_COMBO_POPUP_H */
