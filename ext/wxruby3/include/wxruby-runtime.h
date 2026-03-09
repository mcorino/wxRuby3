// Copyright (c) 2023 M.J.N. Corino, The Netherlands
//
// This software is released under the MIT license.

/*
 * WxRuby3 runtime support
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

// Debug tracing support
#ifdef __WXRB_DEBUG__
#include <cstdlib>
#include <string>
#include <algorithm>
#include <ctype.h>

class WxRubyTraceGuard
{
public:
  WxRubyTraceGuard(const std::string& trace_id)
  {
    std::string trace_env_id = to_uppercase(trace_id);
    while (!trace_env_id.empty())
    {
      // see if we can find a trace setting which starts with 'WXRUBY_TRACE_'
      // followed by the trace id
      std::string trace_env_var = std::string("WXRUBY_TRACE_") + trace_env_id;
      char* env_val = std::getenv(trace_env_var.c_str());
      if (env_val)
      {
        // trace setting found
        this->_trace_lvl = std::atoi(env_val);
        break; // done
      }
      // see if there is a parent trace category we can check
      std::string::size_type offs = trace_env_id.find_last_of('_');
      if (offs != std::string::npos )
      {
        // reduce the id to possible parent category
        trace_env_id = trace_env_id.substr(0, offs);
      }

      if (offs == std::string::npos || trace_env_id.empty())
      {
        // check for global tracing
        env_val = std::getenv("WXRUBY_TRACE");
        if (env_val)
        {
          // trace setting found
          this->_trace_lvl = std::atoi(env_val);
        }
        break; // done
      }
    }
  }

  int trace_level() { return this->_trace_lvl; }

private:
  std::string to_uppercase(std::string s)
  {
    std::transform(s.begin(), s.end(), s.begin(), [](unsigned char c){ return std::toupper(c); });
    return s;
  }

  int _trace_lvl {};
};

#define WXRUBY_TRACE_GUARD(name, trace_id) static WxRubyTraceGuard name (trace_id);

#define WXRUBY_TRACE_IF(__trace_guard__, __level__) \
  if (__trace_guard__.trace_level() >= __level__) {

#define WXRUBY_TRACE_WITH(__stmt__) __stmt__ ;

#define WXRUBY_TRACE(__stmt__) \
  std::wcout << __stmt__ << std::endl;

#define WXRUBY_TRACE_END }

#else

#define WXRUBY_TRACE_GUARD(name, trace_id)
#define WXRUBY_TRACE_IF(__trace_guard__, __level__)
#define WXRUBY_TRACE_WITH(__stmt__)
#define WXRUBY_TRACE(__stmt__)
#define WXRUBY_TRACE_END

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

WXRUBY_EXPORT bool GC_IsObjectOwned(VALUE object);

#ifdef __cplusplus
extern "C" {
#endif

WXRUBY_EXPORT void wxRuby_InitializeTracking();
WXRUBY_EXPORT void wxRuby_AddTracking(void* ptr, VALUE object);
WXRUBY_EXPORT VALUE wxRuby_FindTracking(void* ptr);
WXRUBY_EXPORT void wxRuby_RemoveTracking(void* ptr);
WXRUBY_EXPORT void wxRuby_UnlinkObject(void* ptr);

#ifdef __cplusplus
}
#endif

#include <unordered_map>

typedef std::unordered_map<void*, VALUE>  TGCTrackingValueMap;
typedef void (* TGCMarkerFunction)(const TGCTrackingValueMap&);

WXRUBY_EXPORT void wxRuby_RegisterTrackingCategory(std::string category, TGCMarkerFunction marker, bool has_data = false);
WXRUBY_EXPORT void wxRuby_RegisterCategoryValue(const std::string &category, void *ptr, VALUE object);
WXRUBY_EXPORT void wxRuby_UnregisterCategoryValue(const std::string &category, void *ptr);
WXRUBY_EXPORT VALUE wxRuby_FindCategoryValue(const std::string &category, void *ptr);
WXRUBY_EXPORT void wxRuby_UnlinkCategoryValue(const std::string &category, void* ptr);

WXRUBY_EXPORT void wxRuby_MarkTracked();

// Defined in wx.i; getting, setting and using swig_type <-> ruby class
// mappings
WXRUBY_EXPORT swig_type_info* wxRuby_GetSwigTypeForClass(VALUE cls);
WXRUBY_EXPORT swig_type_info* wxRuby_GetSwigTypeForClassName(const char* clsname);
WXRUBY_EXPORT void wxRuby_SetSwigTypeForClass(VALUE cls, swig_type_info* ty);
// and wx class names -> Ruby class
WXRUBY_EXPORT void wxRuby_SetRbClassForWxName(const wxString& wx_name, VALUE cls);
WXRUBY_EXPORT VALUE wxRuby_GetRbClassForWxName(const wxString& wx_name);

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

// wxConfigBase helpers
#include <wx/config.h>
WXRUBY_EXPORT bool wxRuby_IsRubyConfig(VALUE rbConfig);
WXRUBY_EXPORT wxConfigBase* wxRuby_Ruby2ConfigBase(VALUE rbHash);
WXRUBY_EXPORT VALUE wxRuby_ConfigBase2Ruby(wxConfigBase* config);

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
