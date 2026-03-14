// Copyright (c) 2023 M.J.N. Corino, The Netherlands
//
// This software is released under the MIT license.

/*
 * WxRuby3 Wx::MBConv classes
 */

#include <wx/strconv.h>
#include <memory>

static VALUE cWxMBConv;

// instance variable for MBConv classes
static const char * __iv_cMBConv_conv_id = "@conv_id";

static VALUE wx_MBConv_initialize(int argc, VALUE *argv, VALUE self)
{
  static const std::string classname {"Wx::MBConv"};
  if (classname != rb_obj_classname(self))
  {
    rb_raise(rb_eNameError,"accessing abstract class or protected constructor");
    return Qnil;
  }
  if (argc > 0)
  {
    rb_raise(rb_eArgError, "wrong # of arguments(%d for 0)", argc);
    return Qnil;
  }
  return self;
}

// instance variable for derived Wx::CSConv  and Wx::ConvAuto classes
static const char * __iv_csconv_encoding = "@encoding";   // Wx::FontEncoding enum or string

static VALUE wx_CSConv_initialize(int argc, VALUE *argv, VALUE self)
{
  if (argc != 1)
  {
    rb_raise(rb_eArgError, "wrong # of arguments(%d for 1)", argc);
    return Qnil;
  }
  if (!wxRuby_IsEnumValue("FontEncoding", argv[0]) && TYPE(argv[0]) != T_STRING)
  {
    VALUE msg = rb_inspect(argv[0]);
    rb_raise(rb_eTypeError, "expected Wx::FontEncoding or String for 1 but got %s", StringValuePtr(msg));
    return Qnil;
  }
  rb_iv_set(self, __iv_csconv_encoding, argv[0]);
  return self;
}

static VALUE wx_ConvAuto_initialize(int argc, VALUE *argv, VALUE self)
{
  if (argc != 1)
  {
    rb_raise(rb_eArgError, "wrong # of arguments(%d for 1)", argc);
    return Qnil;
  }
  if (!wxRuby_IsEnumValue("FontEncoding", argv[0]))
  {
    VALUE msg = rb_inspect(argv[0]);
    rb_raise(rb_eTypeError, "expected Wx::FontEncoding for 1 but got %s", StringValuePtr(msg));
    return Qnil;
  }
  rb_iv_set(self, __iv_csconv_encoding, argv[0]);
  return self;
}

static WxRuby_ID mbconv_cs_id("CSConv");
static WxRuby_ID mbconv_auto_id("ConvAuto");
static WxRuby_ID mbconv_utf16_id("ConvUTF16");
static WxRuby_ID mbconv_utf32_id("ConvUTF32");
static WxRuby_ID mbconv_utf7_id("ConvUTF7");
static WxRuby_ID mbconv_utf8_id("ConvUTF8");

static void wx_setup_MBConv()
{
  cWxMBConv = rb_define_class_under(mWxCore, "MBConv", rb_cObject);
  rb_define_method(cWxMBConv, "initialize", VALUEFUNC(wx_MBConv_initialize), -1);

  VALUE cWxCSConv = rb_define_class_under(mWxCore, "CSConv", cWxMBConv);
  rb_iv_set(cWxCSConv, __iv_cMBConv_conv_id, ID2SYM(mbconv_cs_id()));
  rb_define_method(cWxCSConv, "initialize", VALUEFUNC(wx_CSConv_initialize), -1);

  VALUE cWxConvAuto = rb_define_class_under(mWxCore, "ConvAuto", cWxMBConv);
  rb_iv_set(cWxCSConv, __iv_cMBConv_conv_id, ID2SYM(mbconv_auto_id()));
  rb_define_method(cWxConvAuto, "initialize", VALUEFUNC(wx_ConvAuto_initialize), -1);

  VALUE cWxMBConvUTF16 = rb_define_class_under(mWxCore, "MBConvUTF16", cWxMBConv);
  rb_iv_set(cWxMBConvUTF16, __iv_cMBConv_conv_id, ID2SYM(mbconv_utf16_id()));

  VALUE cWxMBConvUTF32 = rb_define_class_under(mWxCore, "MBConvUTF32", cWxMBConv);
  rb_iv_set(cWxMBConvUTF32, __iv_cMBConv_conv_id, ID2SYM(mbconv_utf32_id()));

  VALUE cWxMBConvUTF7 = rb_define_class_under(mWxCore, "MBConvUTF7", cWxMBConv);
  rb_iv_set(cWxMBConvUTF7, __iv_cMBConv_conv_id, ID2SYM(mbconv_utf7_id()));

  VALUE cWxMBConvUTF8 = rb_define_class_under(mWxCore, "MBConvUTF8", cWxMBConv);
  rb_iv_set(cWxMBConvUTF8, __iv_cMBConv_conv_id, ID2SYM(mbconv_utf8_id()));
}

WXRB_EXPORT_FLAG std::unique_ptr<wxMBConv> wxRuby_MBConv2wxMBConv(VALUE rb_val)
{
  if (rb_obj_is_kind_of(rb_val, cWxMBConv))
  {
    // get id for derived MBConv class
    ID mbconv_id = SYM2ID(rb_iv_get(CLASS_OF(rb_val), __iv_cMBConv_conv_id));
    if (mbconv_id == mbconv_cs_id())
    {
      VALUE encoding = rb_iv_get(rb_val, __iv_csconv_encoding);
      if (TYPE(encoding) == T_STRING)
        return std::make_unique<wxCSConv> (RSTR_TO_WXSTR(encoding));
      else
      {
        int enc_val;
        wxRuby_GetEnumValue("FontEncoding", encoding, enc_val);
        return std::make_unique<wxCSConv> (static_cast<wxFontEncoding> (enc_val));
      }
    }
    else if (mbconv_id == mbconv_auto_id())
    {
      VALUE encoding = rb_iv_get(rb_val, __iv_csconv_encoding);
      int enc_val;
      wxRuby_GetEnumValue("FontEncoding", encoding, enc_val);
      return std::make_unique<wxConvAuto> (static_cast<wxFontEncoding> (enc_val));
    }
    else if (mbconv_id == mbconv_utf16_id())
    {
      return std::make_unique<wxMBConvUTF16> ();
    }
    else if (mbconv_id == mbconv_utf32_id())
    {
      return std::make_unique<wxMBConvUTF32> ();
    }
    else if (mbconv_id == mbconv_utf7_id())
    {
      return std::make_unique<wxMBConvUTF7> ();
    }
    else if (mbconv_id == mbconv_utf8_id())
    {
      return std::make_unique<wxMBConvUTF8> ();
    }
  }
  return {};
}
