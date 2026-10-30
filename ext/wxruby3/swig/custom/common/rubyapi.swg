/* -----------------------------------------------------------------------------
 * Ruby API portion that goes into the runtime
 *
 * Customized for wxRuby3.
 * Copyright (c) 2023 M.J.N. Corino, The Netherlands
 *
 * This software is released under the MIT license.
 * ----------------------------------------------------------------------------- */

#ifdef __cplusplus
extern "C" {
#endif

WXRUBY_EXPORT VALUE
SWIG_wxRuby_AppendOutput(VALUE target, VALUE o, int is_void);

#ifdef __cplusplus
}
#endif

/* SWIG >= 4.3.0 version */
inline VALUE
SWIG_Ruby_AppendOutput(VALUE target, VALUE o, int is_void)
{
  return SWIG_wxRuby_AppendOutput(target, o, is_void);
}

/* SWIG < 4.3.0 version */
inline VALUE
SWIG_Ruby_AppendOutput(VALUE target, VALUE o)
{
  return SWIG_wxRuby_AppendOutput(target, o, -1);
}
