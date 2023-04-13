
#undef _

#include <exception>
#include <string>

#include <wx/wx.h>

typedef VALUE (*RUBY_INVOKE_FUNC) (VALUE);

namespace Swig {
  /* Base class for director exceptions */
  class DirectorException : public std::exception
  {
  protected:
    VALUE swig_error;
    std::string swig_msg;
  protected:
    DirectorException(VALUE error) : swig_error(error) { }
    DirectorException(VALUE error, const char *hdr, const char *msg ="") : swig_error(error), swig_msg(hdr)
    {
      if (msg[0])
      {
        swig_msg += " ";
        swig_msg += msg;
      }
      if (swig_msg.size())
      {
        VALUE str = rb_str_new(swig_msg.data(), swig_msg.size());
        swig_error = rb_exc_new3(error, str);
      }
      else
      {
        swig_error = error;
      }
    }
  public:
    virtual ~DirectorException() throw() { }
    VALUE getType() const
    {
      return CLASS_OF(swig_error);
    }
    VALUE getError() const
    {
      return swig_error;
    }
    /* Deprecated, use what() instead */
    const std::string& getMessage() const
    {
      return swig_msg;
    }
    const char *what() const throw()
    {
      return swig_msg.c_str();
    }
  };
  class DirectorRubyException : public DirectorException
  {
  public:
    DirectorRubyException(const char *exname, const char *msg="")
      : DirectorException(rb_eRuntimeError, exname, msg)
    {
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

  VALUE get_exception () { return rb_gv_get ("$!"); }

  ID id () { return this->fn_id_; }

protected:
  struct FuncArgs
  {
    virtual ~FuncArgs () {}
    virtual VALUE rb_invoke (ID fnid) const = 0;
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
        VALUE msg = rb_eval_string ("$!.message+\"\\n\"+$!.backtrace.join(\"\\n\")");
        const char *exc_name = rb_obj_classname(rexc);
        wxLogDebug("%s : %s", exc_name, StringValuePtr(msg));
        throw Swig::DirectorRubyException(exc_name, StringValuePtr(msg));
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
     : receiver_ (rcvr), args_ (args) {}
    virtual ~FuncArgArray () {}

    virtual VALUE rb_invoke (ID fnid) const
    {
      return rb_apply (this->receiver_, fnid, this->args_);
    }

    VALUE receiver_;
    VALUE args_;
  };

  struct FuncArgList : public FuncArgs
  {
    FuncArgList (VALUE rcvr, int argc, VALUE* args)
     : receiver_ (rcvr), argc_ (argc), args_ (args) {}
    virtual ~FuncArgList () {}

    virtual VALUE rb_invoke (ID fnid) const
    {
      return rb_funcall2 (this->receiver_, fnid, this->argc_, this->args_);
    }

    VALUE receiver_;
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
