// wxRuby3 Wx::Enum class embedded implementation
// Copyright (c) M.J.N. Corino, The Netherlands

VALUE cWxEnum;

// instance variable for Enum class
static const char * __iv_cEnum_value = "@value";

// Enum class singleton class
static VALUE cEnum_Singleton;
// instance variable for Enum class singleton class (hash registry of Enum classes)
static const char * __iv_Enum_sc_enums = "@enums";

// instance variables for derived Enum class singleton classes
static const char * __iv_enum_klass_values = "@values";   // hash map of all value instances of derived Enum (by integer value)
static const char * __iv_enum_klass_values_by_name = "@values_by_name";   // hash map of all value instances of derived Enum
static const char * __iv_enum_klass_name = "@name";       // unscoped name of derived Enum

static VALUE wx_Enum_initialize(int argc, VALUE *argv, VALUE self)
{
  if ((argc < 1) || (argc > 1))
  {
    rb_raise(rb_eArgError, "wrong # of arguments(%d for 1)", argc); return Qnil;
  }
  rb_iv_set(self, __iv_cEnum_value, rb_funcall(argv[0], rb_intern("to_i"), 0, 0));
  return self;
}

static VALUE wx_Enum_coerce(int argc, VALUE *argv, VALUE self)
{
  if ((argc < 1) || (argc > 1))
  {
    rb_raise(rb_eArgError, "wrong # of arguments(%d for 1)", argc); return Qnil;
  }
  if (!rb_obj_is_kind_of(argv[0], rb_cNumeric))
  {
    VALUE str = rb_inspect(argv[0]);
    rb_raise(rb_eTypeError,
             "Unable to coerce %s to be compatible with Enum",
             StringValuePtr(str));
    return Qnil;
  }
  VALUE result = rb_ary_new();
  rb_ary_push(result, rb_iv_get(self, __iv_cEnum_value));
  rb_ary_push(result, rb_funcall(argv[0], rb_intern("to_i"), 0, 0));
  return result;
}

static VALUE wx_Enum_is_integer(int argc, VALUE *argv, VALUE self)
{
  if ((argc < 0) || (argc > 0))
  {
    rb_raise(rb_eArgError, "wrong # of arguments(%d for 0)", argc); return Qnil;
  }
  return Qtrue;
}

static VALUE wx_Enum_is_real(int argc, VALUE *argv, VALUE self)
{
  if ((argc < 0) || (argc > 0))
  {
    rb_raise(rb_eArgError, "wrong # of arguments(%d for 0)", argc); return Qnil;
  }
  return Qfalse;
}

static VALUE wx_Enum_method_missing(int argc, VALUE *argv, VALUE self)
{
  if (argc < 1)
  {
    rb_raise(rb_eArgError, "wrong # of arguments(%d for 1)", argc); return Qnil;
  }
  VALUE value = rb_iv_get(self, __iv_cEnum_value);
  return rb_funcall2(value, rb_to_id(argv[0]), argc-1, (argv+1));
}

static VALUE wx_Enum_is_equal(int argc, VALUE *argv, VALUE self)
{
  if ((argc < 1) || (argc > 1))
  {
    rb_raise(rb_eArgError, "wrong # of arguments(%d for 1)", argc); return Qnil;
  }
  if (CLASS_OF(self) == CLASS_OF(argv[0]) &&
        NUM2INT(rb_iv_get(self, __iv_cEnum_value)) == NUM2INT(rb_iv_get(argv[0], __iv_cEnum_value)))
    return Qtrue;
  else
    return Qfalse;
}

static VALUE wx_Enum_compare(int argc, VALUE *argv, VALUE self)
{
  if ((argc < 1) || (argc > 1))
  {
    rb_raise(rb_eArgError, "wrong # of arguments(%d for 1)", argc); return Qnil;
  }
  if (rb_obj_is_kind_of(argv[0], cWxEnum))
  {
    return rb_funcall(rb_iv_get(self, __iv_cEnum_value), rb_intern("<=>"), 1, rb_iv_get(argv[0], __iv_cEnum_value), 0);
  }
  else if (rb_obj_is_kind_of(argv[0], rb_cNumeric))
  {
    return rb_funcall(rb_iv_get(self, __iv_cEnum_value), rb_intern("<=>"), 1, argv[0], 0);
  }
  VALUE str = rb_inspect(argv[0]);
  rb_raise(rb_eArgError,
           "Failed to compare Enum with %s",
           StringValuePtr(str));
  return Qnil;
}

static VALUE wx_Enum_inspect(int argc, VALUE *argv, VALUE self)
{
  if ((argc < 0) || (argc > 0))
  {
    rb_raise(rb_eArgError, "wrong # of arguments(%d for 0)", argc); return Qnil;
  }
  VALUE str = rb_str_new2(rb_class2name(CLASS_OF(self)));
  rb_str_cat2(str, "<");
  rb_funcall(str,
             rb_intern("<<"),
             1,
             rb_funcall(rb_iv_get(self, __iv_cEnum_value),
                        rb_intern("to_s"),
                        0,
                        0),
             0);
  rb_str_cat2(str, ">");
  return str;
}

static VALUE wx_Enum_sc_get_enum_class(int argc, VALUE *argv, VALUE self)
{
  if ((argc < 1) || (argc > 1))
  {
    rb_raise(rb_eArgError, "wrong # of arguments(%d for 1)", argc); return Qnil;
  }
  return rb_hash_aref(rb_iv_get(cEnum_Singleton, __iv_Enum_sc_enums), rb_to_symbol(argv[0]));
}

static VALUE wx_Enum_sc_create_enum_class(int argc, VALUE *argv, VALUE self)
{
  if ((argc < 2) || (argc > 2))
  {
    rb_raise(rb_eArgError, "wrong # of arguments(%d for 2)", argc); return Qnil;
  }
  VALUE enum_name = rb_to_symbol(argv[0]);
  if (TYPE(argv[1]) != T_HASH)
  {
    VALUE str = rb_inspect(argv[1]);
    rb_raise(rb_eArgError,
             "Invalid enum_values; expected Hash but got %s.",
             StringValuePtr(str));
    return Qnil;
  }
  ID id_new = rb_intern("new");
  ID id_to_i = rb_intern("to_i");
  ID id_const_set = rb_intern("const_set");
  VALUE enum_klass = rb_funcall(rb_cClass, id_new, 1, cWxEnum, 0);
  VALUE enum_values = rb_funcall(argv[1], rb_intern("keys"), 0, 0);
  for (int i=0; i<RARRAY_LEN(enum_values) ;++i)
  {
    VALUE enum_value_name = rb_ary_entry(enum_values, i);
    VALUE enum_value_num = rb_funcall(rb_hash_aref(argv[1], enum_value_name), id_to_i, 0, 0);
    VALUE enum_value = rb_funcall(enum_klass, id_new, 1, enum_value_num, 0);
    rb_funcall(enum_klass, id_const_set, 2, enum_value_name, enum_value, 0);
  }
  rb_hash_aset(rb_iv_get(cEnum_Singleton, __iv_Enum_sc_enums), enum_name, enum_klass);
  return enum_klass;
}

static void setup_Enum_singleton_class()
{
  cEnum_Singleton = rb_funcall(cWxEnum, rb_intern("singleton_class"), 0, 0);
  rb_iv_set(cEnum_Singleton, __iv_Enum_sc_enums, rb_hash_new());
  rb_define_method(cEnum_Singleton, "create", VALUEFUNC(wx_Enum_sc_create_enum_class), -1);
  rb_define_singleton_method(cWxEnum, "[]", VALUEFUNC(wx_Enum_sc_get_enum_class), -1);
}

WXRB_EXPORT_FLAG VALUE wxRuby_GetEnumClass(const char* enum_class_name_cstr)
{
  VALUE enum_hash = rb_iv_get(cEnum_Singleton, __iv_Enum_sc_enums);
  return rb_hash_aref(enum_hash, rb_str_new2(enum_class_name_cstr));
}

static VALUE wx_Enum_sc_get_enum_value(int argc, VALUE *argv, VALUE self)
{
  if ((argc < 1) || (argc > 1))
  {
    rb_raise(rb_eArgError, "wrong # of arguments(%d for 1)", argc); return Qnil;
  }
  VALUE enum_singleton_klass = rb_funcall(self, rb_intern("singleton_class"), 0, 0);
  return rb_hash_aref(rb_iv_get(enum_singleton_klass, __iv_enum_klass_values_by_name), rb_to_symbol(argv[0]));
}

WXRB_EXPORT_FLAG VALUE wxRuby_CreateEnumClass(const char* enum_class_name_cstr)
{
  VALUE enum_klass = rb_funcall(rb_cClass, rb_intern("new"), 1, cWxEnum, 0);
  rb_define_singleton_method(enum_klass, "[]", VALUEFUNC(wx_Enum_sc_get_enum_value), -1);
  VALUE enum_singleton_klass = rb_funcall(enum_klass, rb_intern("singleton_class"), 0, 0);
  rb_iv_set(enum_singleton_klass, __iv_enum_klass_values, rb_hash_new());
  rb_iv_set(enum_singleton_klass, __iv_enum_klass_values_by_name, rb_hash_new());
  rb_iv_set(enum_singleton_klass, __iv_enum_klass_name, rb_str_new2(enum_class_name_cstr));
  rb_hash_aset(rb_iv_get(cEnum_Singleton, __iv_Enum_sc_enums),
               ID2SYM(rb_intern(enum_class_name_cstr)),
               enum_klass);
  return enum_klass;
}

WXRB_EXPORT_FLAG VALUE wxRuby_AddEnumValue(VALUE enum_klass, const char* enum_value_name_cstr, VALUE enum_value_num)
{
  VALUE enum_value_name = ID2SYM(rb_intern(enum_value_name_cstr));
  VALUE enum_value = rb_funcall(enum_klass, rb_intern("new"), 1, enum_value_num, 0);
  VALUE enum_singleton_klass = rb_funcall(enum_klass, rb_intern("singleton_class"), 0, 0);
  rb_hash_aset(rb_iv_get(enum_singleton_klass, __iv_enum_klass_values), enum_value_num, enum_value);
  rb_hash_aset(rb_iv_get(enum_singleton_klass, __iv_enum_klass_values_by_name), enum_value_name, enum_value);
  rb_funcall(enum_klass, rb_intern("const_set"), 2, enum_value_name, enum_value, 0);
  return enum_value;
}

WXRB_EXPORT_FLAG VALUE wxRuby_GetEnumValueObject(const char* enum_wx_class_name_cstr, int enum_val)
{
  if (!enum_wx_class_name_cstr)
  {
    rb_raise(rb_eArgError,
             "Missing enum class name.");
  }
  const char *enum_class_name = enum_wx_class_name_cstr;
  if (strncmp(enum_class_name, "wx", 2) == 0)
    enum_class_name += 2;
  VALUE enum_hash = rb_iv_get(cEnum_Singleton, __iv_Enum_sc_enums);
  VALUE enum_klass = rb_hash_aref(enum_hash, ID2SYM(rb_intern(enum_class_name)));
  VALUE enum_singleton_klass = rb_funcall(enum_klass, rb_intern("singleton_class"), 0, 0);
  VALUE enum_values_hash = rb_iv_get(enum_singleton_klass, __iv_enum_klass_values);
  VALUE enum_value = rb_hash_aref(enum_values_hash, INT2NUM(enum_val));
  if (enum_value == Qnil)
  {
    rb_raise(rb_eArgError,
             "Invalid enum value %d for enum class %s.",
             enum_val,
             enum_class_name);
  }
  return enum_value;
}

WXRB_EXPORT_FLAG int wxRuby_GetEnumValue(const char* enum_wx_class_name_cstr, VALUE rb_enum_val)
{
  if (!enum_wx_class_name_cstr)
  {
    rb_raise(rb_eArgError,
             "Missing enum class name.");
  }
  if (rb_obj_is_kind_of(rb_enum_val, cWxEnum))
  {
    VALUE enum_singleton_klass = rb_funcall(CLASS_OF(rb_enum_val), rb_intern("singleton_class"), 0, 0);
    VALUE rb_enum_class_name = rb_iv_get(enum_singleton_klass, __iv_enum_klass_name);
    const char *enum_class_name = enum_wx_class_name_cstr;
    if (strncmp(enum_class_name, "wx", 2) == 0)
      enum_class_name += 2;
    if (strcmp(enum_class_name, StringValuePtr(rb_enum_class_name)) == 0)
    {
      return NUM2INT(rb_iv_get(rb_enum_val, __iv_cEnum_value));
    }
    else
    {
      rb_raise(rb_eArgError,
               "Invalid enum class. Expected %s got %s.",
               enum_class_name,
               StringValuePtr(rb_enum_class_name));
    }
  }
  else
  {
    VALUE str = rb_inspect(rb_enum_val);
    rb_raise(rb_eArgError,
             "Invalid enum value. Got %s.",
             StringValuePtr(str));
  }
  return 0;
}

WXRB_EXPORT_FLAG bool wxRuby_IsEnumValue(const char* enum_wx_class_name_cstr, VALUE rb_enum_val)
{
  if (!enum_wx_class_name_cstr)
  {
    rb_raise(rb_eArgError,
             "Missing enum class name.");
  }
  if (rb_obj_is_kind_of(rb_enum_val, cWxEnum))
  {
    VALUE enum_singleton_klass = rb_funcall(CLASS_OF(rb_enum_val), rb_intern("singleton_class"), 0, 0);
    VALUE rb_enum_class_name = rb_iv_get(enum_singleton_klass, __iv_enum_klass_name);
    const char *enum_class_name = enum_wx_class_name_cstr;
    if (strncmp(enum_class_name, "wx", 2) == 0)
      enum_class_name += 2;
    return (strcmp(enum_class_name, StringValuePtr(rb_enum_class_name)) == 0);
  }
  return false;
}
