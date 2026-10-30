/* -----------------------------------------------------------------------------
 * rubyrun.swg
 *
 * This file contains the runtime support for Ruby modules
 * and includes code for managing global variables and pointer
 * type checking.
 *
 * Customized for wxRuby3.
 * Copyright (c) 2023 M.J.N. Corino, The Netherlands
 *
 * This software is released under the MIT license.
 * ----------------------------------------------------------------------------- */

/* For backward compatibility only */
#define SWIG_POINTER_EXCEPTION  0

/* for raw pointers */
#define SWIG_ConvertPtr(obj, pptr, type, flags)         SWIG_Ruby_ConvertPtrAndOwn(obj, pptr, type, flags, 0)
#define SWIG_ConvertPtrAndOwn(obj,pptr,type,flags,own)  SWIG_Ruby_ConvertPtrAndOwn(obj, pptr, type, flags, own)
#define SWIG_NewPointerObj(ptr, type, flags)            SWIG_Ruby_NewPointerObj(ptr, type, flags)
#define SWIG_AcquirePtr(ptr, own)                       SWIG_Ruby_AcquirePtr(ptr, own)
#define swig_owntype                                    swig_ruby_owntype

/* for raw packed data */
#define SWIG_ConvertPacked(obj, ptr, sz, ty)            SWIG_Ruby_ConvertPacked(obj, ptr, sz, ty, flags)
#define SWIG_NewPackedObj(ptr, sz, type)                SWIG_Ruby_NewPackedObj(ptr, sz, type)

/* for class or struct pointers */
#define SWIG_ConvertInstance(obj, pptr, type, flags)    SWIG_ConvertPtr(obj, pptr, type, flags)
#define SWIG_NewInstanceObj(ptr, type, flags)           SWIG_NewPointerObj(ptr, type, flags)

/* for C or C++ function pointers */
#define SWIG_ConvertFunctionPtr(obj, pptr, type)        SWIG_ConvertPtr(obj, pptr, type, 0)
#define SWIG_NewFunctionPtrObj(ptr, type)               SWIG_NewPointerObj(ptr, type, 0)

/* for C++ member pointers, ie, member methods */
#define SWIG_ConvertMember(obj, ptr, sz, ty)            SWIG_Ruby_ConvertPacked(obj, ptr, sz, ty)
#define SWIG_NewMemberObj(ptr, sz, type)                SWIG_Ruby_NewPackedObj(ptr, sz, type)


/* Runtime API */

#define SWIG_GetModule(clientdata)                      SWIG_Ruby_GetModule(clientdata)
#define SWIG_SetModule(clientdata, pointer) 		SWIG_Ruby_SetModule(pointer)


/* Error manipulation */

#define SWIG_ErrorType(code)                            SWIG_Ruby_ErrorType(code)               
#define SWIG_Error(code, msg)            		rb_raise(SWIG_Ruby_ErrorType(code), "%s", msg)
#define SWIG_fail                        		goto fail				 


/* Ruby-specific SWIG API */

#define SWIG_InitRuntime()                              SWIG_Ruby_InitRuntime()              
#define SWIG_define_class(ty)                        	SWIG_Ruby_define_class(ty)
#define SWIG_NewClassInstance(value, ty)             	SWIG_Ruby_NewClassInstance(value, ty)
#define SWIG_MangleStr(value)                        	SWIG_Ruby_MangleStr(value)		  
#define SWIG_CheckConvert(value, ty)                 	SWIG_Ruby_CheckConvert(value, ty)	  

#include "assert.h"

/* -----------------------------------------------------------------------------
 * pointers/data manipulation
 * ----------------------------------------------------------------------------- */

#ifdef __cplusplus
extern "C" {
#endif

typedef struct WXRUBY_EXPORT swig_class {
  VALUE klass;
  VALUE mImpl;
  void  (*mark)(void *);
  void  (*destroy)(void *);
  int trackObjects;
} swig_class;

#if SWIG_VERSION >= 0x040400
extern ID swig_lowerthan_id;
#endif

/*
  If your swig extension is to be run within an embedded ruby and has
  director callbacks, you should set -DRUBY_EMBEDDED during compilation.  
  This will reset ruby's stack frame on each entry point from the main 
  program the first time a virtual director function is invoked (in a 
  non-recursive way).
  If this is not done, you run the risk of Ruby trashing the stack.
*/

#ifdef RUBY_EMBEDDED

#  define SWIG_INIT_STACK                            \
      if ( !swig_virtual_calls ) { RUBY_INIT_STACK } \
      ++swig_virtual_calls;
#  define SWIG_RELEASE_STACK --swig_virtual_calls;
#  define Ruby_DirectorTypeMismatchException(x) \
          rb_raise( rb_eTypeError, "%s", x ); return c_result;

      static unsigned int swig_virtual_calls = 0;

#else  /* normal non-embedded extension */

#  define SWIG_INIT_STACK
#  define SWIG_RELEASE_STACK
#  define Ruby_DirectorTypeMismatchException(x) \
          throw Swig::DirectorTypeMismatchException( x );

#endif  /* RUBY_EMBEDDED */


/* This code checks to see if the Ruby object being raised as part
   of an exception inherits from the Ruby class Exception.  If so,
   the object is simply returned.  If not, then a new Ruby exception
   object is created and that will be returned to Ruby.*/
WXRUBY_EXPORT VALUE
SWIG_Ruby_ExceptionType(swig_type_info *desc, VALUE obj);

/* Initialize Ruby runtime support */
WXRUBY_EXPORT void
SWIG_Ruby_InitRuntime(void);

/* Define Ruby class for C type */
WXRUBY_EXPORT void
SWIG_Ruby_define_class(swig_type_info *type);

/* Create a new pointer object */
WXRUBY_EXPORT VALUE
SWIG_Ruby_NewPointerObj(void *ptr, swig_type_info *type, int flags);

/* Create a new class instance (always owned) */
WXRUBY_EXPORT VALUE
SWIG_Ruby_NewClassInstance(VALUE klass, swig_type_info *type);

/* Get type mangle from class name */
WXRUBY_EXPORT char *
SWIG_Ruby_MangleStr(VALUE obj);

/* Acquire a pointer value */
typedef struct WXRUBY_EXPORT swig_ruby_owntype {
  void (*datafree)(void *);
  int own;
} swig_ruby_owntype;

WXRUBY_EXPORT swig_ruby_owntype
SWIG_Ruby_AcquirePtr(VALUE obj, swig_ruby_owntype own);

/* Convert a pointer value */
WXRUBY_EXPORT int
SWIG_Ruby_ConvertPtrAndOwn(VALUE obj, void **ptr, swig_type_info *ty, int flags, swig_ruby_owntype *own);

/* Check convert */
WXRUBY_EXPORT int
SWIG_Ruby_CheckConvert(VALUE obj, swig_type_info *ty);

WXRUBY_EXPORT VALUE
SWIG_Ruby_NewPackedObj(void *ptr, int sz, swig_type_info *type);

/* Convert a packed pointer value */
WXRUBY_EXPORT int
SWIG_Ruby_ConvertPacked(VALUE obj, void *ptr, int sz, swig_type_info *ty);

WXRUBY_EXPORT swig_module_info *
SWIG_Ruby_GetModule(void *SWIGUNUSEDPARM(clientdata));

WXRUBY_EXPORT void
SWIG_Ruby_SetModule(swig_module_info *pointer);

/* This function can be used to check whether a proc or method or similarly
   callable function has been passed.  Usually used in a %typecheck, like:

   %typecheck(c_callback_t, precedence=SWIG_TYPECHECK_POINTER) {
        $result = SWIG_Ruby_isCallable( $input );
   }
 */
WXRUBY_EXPORT
int SWIG_Ruby_isCallable( VALUE proc );

/* This function can be used to check the arity (number of arguments)
   a proc or method can take.  Usually used in a %typecheck.
   Valid arities will be that equal to minimal or those < 0
   which indicate a variable number of parameters at the end.
 */
WXRUBY_EXPORT
int SWIG_Ruby_arity( VALUE proc, int minimal );

#ifdef __cplusplus
}
#endif
