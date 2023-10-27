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
SWIG_Ruby_AppendOutput(VALUE target, VALUE o);

#ifdef __cplusplus
}
#endif
