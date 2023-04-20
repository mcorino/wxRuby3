/*
 * WxRuby3 runtime support
 * Copyright (c) M.J.N. Corino, The Netherlands
 */

#include <memory>

// Class for static ID initializers
class WxRuby_ID
{
public:
  WxRuby_ID(const char* nm) : name_ (nm) {}
  WxRuby_ID(const WxRuby_ID& other) : name_(other.name_), id_(other.id_) {}
  WxRuby_ID(WxRuby_ID&&) = delete;

  ID get_id ()
  {
    if (this->id_ == ID())
    {
      this->id_ = rb_intern(this->name_);
    }
    return this->id_;
  }

  ID operator ()() { return this->get_id(); }

  VALUE get_sym ()
  {
    return ID2SYM(this->get_id());
  }

private:
  const char* name_;
  ID id_ {};
};

// Exported runtime helper methods

#ifdef __WXRB_DEBUG__
WXRUBY_EXPORT int wxRuby_TraceLevel();
#endif

WXRUBY_EXPORT VALUE wxRuby_Funcall(VALUE rcvr, ID func, int argc, ...);
WXRUBY_EXPORT VALUE wxRuby_Funcall(bool& ex_caught, VALUE rcvr, ID func, int argc, ...);
WXRUBY_EXPORT VALUE wxRuby_Funcall(VALUE rcvr, ID func, VALUE args);
WXRUBY_EXPORT VALUE wxRuby_Funcall(bool& ex_caught, VALUE rcvr, ID func, VALUE args);

WXRUBY_EXPORT bool wxRuby_IsAppRunning();
WXRUBY_EXPORT void wxRuby_ExitMainLoop(VALUE exception = Qnil);
WXRUBY_EXPORT void wxRuby_PrintException(VALUE err);
typedef void (*WXRBMarkFunction)();
WXRUBY_EXPORT void wxRuby_AppendMarker(WXRBMarkFunction marker);

WXRUBY_EXPORT VALUE wxRuby_GetTopLevelWindowClass(); // used for wxWindow typemap in typemap.i
WXRUBY_EXPORT bool GC_IsWindowDeleted(void *ptr);

// Defined in wx.i; getting, setting and using swig_type <-> ruby class
// mappings
WXRUBY_EXPORT swig_type_info* wxRuby_GetSwigTypeForClass(VALUE cls);
WXRUBY_EXPORT void wxRuby_SetSwigTypeForClass(VALUE cls, swig_type_info* ty);

// Common wrapping functions
WXRUBY_EXPORT VALUE wxRuby_WrapWxObjectInRuby(wxObject* obj);
#ifdef __WXRB_DEBUG__
WXRUBY_EXPORT VALUE wxRuby_WrapWxEventInRuby(void* rcvr, wxEvent* event);
#else
WXRUBY_EXPORT VALUE wxRuby_WrapWxEventInRuby(wxEvent* event);
#endif

// event handling helpers
WXRUBY_EXPORT VALUE wxRuby_GetEventTypeClassMap();
WXRUBY_EXPORT VALUE wxRuby_GetDefaultEventClass ();
WXRUBY_EXPORT void wxRuby_ReleaseEvtHandlerProcs(void* evt_handler);

WXRUBY_EXPORT bool wxRuby_IsNativeMethod(VALUE object, ID method_id);

WXRUBY_EXPORT VALUE wxRuby_GetWindowClass();
WXRUBY_EXPORT VALUE wxRuby_GetDialogClass();

// Enum helpers
WXRUBY_EXPORT VALUE wxRuby_GetEnumClass(const char* enum_class_name_cstr);
WXRUBY_EXPORT VALUE wxRuby_CreateEnumClass(const char* enum_class_name_cstr);
WXRUBY_EXPORT VALUE wxRuby_AddEnumValue(VALUE enum_klass, const char* enum_value_name_cstr, VALUE enum_value_num);
WXRUBY_EXPORT VALUE wxRuby_GetEnumValueObject(const char* enum_wx_class_name_cstr, int enum_val);
WXRUBY_EXPORT bool wxRuby_GetEnumValue(const char* enum_class_name_cstr, VALUE rb_enum_val, int &c_eval);
WXRUBY_EXPORT bool wxRuby_IsAnEnum(VALUE rb_val);
WXRUBY_EXPORT bool wxRuby_IsEnumValue(const char* enum_wx_class_name_cstr, VALUE rb_enum_val);

// Colour type mapping helpers
WXRUBY_EXPORT bool wxRuby_IsRubyColour(VALUE rbcol);
WXRUBY_EXPORT wxColour wxRuby_ColourFromRuby(VALUE rbcol);
WXRUBY_EXPORT VALUE wxRuby_ColourToRuby(const wxColour& col);

// Font type mapping helpers
WXRUBY_EXPORT bool wxRuby_IsRubyFont(VALUE rbfont);
WXRUBY_EXPORT wxFont wxRuby_FontFromRuby(VALUE rbfont);
WXRUBY_EXPORT VALUE wxRuby_FontToRuby(const wxFont& font);

#if wxUSE_VARIANT
// Variant support
WXRUBY_EXPORT VALUE& operator << (VALUE &value, const wxVariant &variant);
WXRUBY_EXPORT wxVariant& operator << (wxVariant &variant, const VALUE &value);
WXRUBY_EXPORT wxVariant wxRuby_ConvertRbValue2Variant(VALUE rbval);
#endif
