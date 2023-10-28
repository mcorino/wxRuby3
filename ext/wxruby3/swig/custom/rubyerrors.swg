/* -----------------------------------------------------------------------------
 * error manipulation
 *
 * Customized for wxRuby3.
 * Copyright (c) 2023 M.J.N. Corino, The Netherlands
 *
 * This software is released under the MIT license.
 * ----------------------------------------------------------------------------- */


/* Define some additional error types */
#define SWIG_ObjectPreviouslyDeletedError  -100


/* Define custom exceptions for errors that do not map to existing Ruby
   exceptions.  Note this only works for C++ since a global cannot be
   initialized by a function in C.  For C, fallback to rb_eRuntimeError.*/

WXRUBY_EXPORT VALUE
getNullReferenceError(void);

WXRUBY_EXPORT VALUE
getObjectPreviouslyDeletedError(void);

WXRUBY_EXPORT VALUE
SWIG_Ruby_ErrorType(int SWIG_code);

/* This function is called when a user inputs a wrong argument to
   a method.
 */
WXRUBY_EXPORT
const char* Ruby_Format_TypeError( const char* msg,
				   const char* type, 
				   const char* name, 
				   const int argn,
				   VALUE input );

/* This function is called when an overloaded method fails */
WXRUBY_EXPORT
void Ruby_Format_OverloadedError(
				 const int argc,
				 const int maxargs,
				 const char* method, 
				 const char* prototypes 
				 );
