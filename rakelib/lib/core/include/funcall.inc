// Copyright (c) 2023 M.J.N. Corino, The Netherlands
//
// This software is released under the MIT license.

#undef _

#include <exception>
#include <string>

#include <wx/wx.h>

typedef VALUE (*RUBY_INVOKE_FUNC) (VALUE);

VALUE rb_exc_set_backtrace(VALUE, VALUE);
VALUE rb_get_backtrace(VALUE);

namespace Swig
{
  class WXRB_EXPORT_FLAG DirectorRubyException : public DirectorException
  {
  public:
    DirectorRubyException(VALUE error, VALUE rcvr, ID fn_id)
      : DirectorException(Qnil)
    {
      VALUE msg = rb_sprintf("Caught exception in SWIG director method for %s#%s : ", rb_class2name(CLASS_OF(rcvr)), rb_id2name(fn_id));
      rb_str_append(msg, rb_funcall(error, rb_intern("message"), 0));
      this->swig_msg = StringValuePtr(msg);
      swig_error = rb_exc_new_str(rb_eRuntimeError, msg);
      VALUE bt = rb_funcall(error, rb_intern("backtrace"), 0);
      rb_funcall(swig_error, rb_intern("set_backtrace"), 1, bt);
    }
  };
}

class WXRuby_RBFuncall
{
public:
  WXRuby_RBFuncall (ID fnid, bool throw_on_ex=true)
   : fn_id_ (fnid),
     throw_on_ex_ (throw_on_ex),
     ex_caught_ (false)
  {
  }
  WXRuby_RBFuncall (const char* fn, bool throw_on_ex=true)
  : fn_id_ (rb_intern (fn)),
    throw_on_ex_ (throw_on_ex),
    ex_caught_ (false)
  {
  }
  ~WXRuby_RBFuncall () {}

  VALUE invoke (VALUE rcvr, VALUE args)
  {
    return this->_invoke (FuncArgArray (rcvr, args));
  }
  VALUE invoke (VALUE rcvr, int argc, VALUE *args)
  {
    return this->_invoke (FuncArgList (rcvr, argc, args));
  }
  VALUE invoke (VALUE rcvr)
  {
    return this->_invoke (FuncArgList (rcvr, 0, 0));
  }

  bool has_caught_exception () { return this->ex_caught_; }

  VALUE get_exception () { return rb_errinfo(); }

  ID id () { return this->fn_id_; }

protected:
  struct FuncArgs
  {
    FuncArgs(VALUE rcvr) : receiver_(rcvr) {}
    virtual ~FuncArgs () {}
    virtual VALUE rb_invoke (ID fnid) const = 0;

    VALUE receiver_;
  };

  VALUE _invoke (const FuncArgs& fa)
  {
    this->ex_caught_ = false; // reset

    int invoke_state = 0;
    HelperArgs ha (*this, fa);
    VALUE result = rb_protect (RUBY_INVOKE_FUNC(WXRuby_RBFuncall::invoke_helper),
                               (VALUE)&ha,
                               &invoke_state);
    if (invoke_state)
    {
      if (this->throw_on_ex_)
      {
        // handle exception
        VALUE rexc = this->get_exception ();
        throw Swig::DirectorRubyException(rexc, fa.receiver_, this->fn_id_);
      }
      else
      {
        this->ex_caught_ = true;
      }
    }
    else
    {
      return result;
    }
    return Qnil;
  }

  struct FuncArgArray : public FuncArgs
  {
    FuncArgArray (VALUE rcvr, VALUE args)
     : FuncArgs (rcvr), args_ (args) {}
    virtual ~FuncArgArray () {}

    virtual VALUE rb_invoke (ID fnid) const
    {
      return rb_apply (this->receiver_, fnid, this->args_);
    }

    VALUE args_;
  };

  struct FuncArgList : public FuncArgs
  {
    FuncArgList (VALUE rcvr, int argc, VALUE* args)
     : FuncArgs (rcvr), argc_ (argc), args_ (args) {}
    virtual ~FuncArgList () {}

    virtual VALUE rb_invoke (ID fnid) const
    {
      return rb_funcall2 (this->receiver_, fnid, this->argc_, this->args_);
    }

    int argc_;
    VALUE* args_;
  };

  VALUE invoke_inner (const FuncArgs& fnargs)
  {
    return fnargs.rb_invoke (this->fn_id_);
  }

  struct HelperArgs
  {
    HelperArgs (WXRuby_RBFuncall& c, const FuncArgs& fa)
     : caller_ (c), fnargs_ (fa) {}

    WXRuby_RBFuncall& caller_;
    const FuncArgs& fnargs_;
  };

  static VALUE invoke_helper (VALUE arg)
  {
    HelperArgs* ha = reinterpret_cast<HelperArgs*> (arg);
    return ha->caller_.invoke_inner (ha->fnargs_);
  }

private:
  ID      fn_id_;
  bool    throw_on_ex_;
  bool    ex_caught_;
};

WXRB_EXPORT_FLAG VALUE wxRuby_Funcall(VALUE rcvr, ID func, int argc, ...)
{
  VALUE *argv;
  va_list ar;

  if (argc > 0)
  {
      long i;

      va_start(ar, argc);

      argv = ALLOCA_N(VALUE, argc);

      for (i = 0; i < argc; i++)
      {
          argv[i] = va_arg(ar, VALUE);
      }
      va_end(ar);
  }
  else
  {
      argv = 0;
  }
  return WXRuby_RBFuncall(func).invoke(rcvr, argc, argv);
}

WXRB_EXPORT_FLAG VALUE wxRuby_Funcall(bool& ex_caught, VALUE rcvr, ID func, int argc, ...)
{
  VALUE *argv;
  va_list ar;

  if (argc > 0)
  {
      long i;

      va_start(ar, argc);

      argv = ALLOCA_N(VALUE, argc);

      for (i = 0; i < argc; i++)
      {
          argv[i] = va_arg(ar, VALUE);
      }
      va_end(ar);
  }
  else
  {
      argv = 0;
  }
  WXRuby_RBFuncall wxrb_fn(func, false);
  VALUE rc = wxrb_fn.invoke(rcvr, argc, argv);
  if ((ex_caught = wxrb_fn.has_caught_exception ()))
  {
    return wxrb_fn.get_exception ();
  }
  else
  {
    return rc;
  }
}

WXRB_EXPORT_FLAG VALUE wxRuby_Funcall(VALUE rcvr, ID func, VALUE args)
{
  return WXRuby_RBFuncall(func).invoke(rcvr, args);
}

WXRB_EXPORT_FLAG VALUE wxRuby_Funcall(bool& ex_caught, VALUE rcvr, ID func, VALUE args)
{
  WXRuby_RBFuncall wxrb_fn(func, false);
  VALUE rc = wxrb_fn.invoke(rcvr, args);
  if ((ex_caught = wxrb_fn.has_caught_exception ()))
  {
    return wxrb_fn.get_exception ();
  }
  else
  {
    return rc;
  }
}
