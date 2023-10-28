// Copyright (c) 2023 M.J.N. Corino, The Netherlands
//
// This software is released under the MIT license.

// SWIG director classes

#include <string>
#include <iostream>
#include <exception>
#include <map>

namespace Swig
{

  /* memory handler */
  struct WXRB_EXPORT_FLAG GCItem
  {
    virtual ~GCItem();

    virtual swig_ruby_owntype get_own() const;
  };

  GCItem::~GCItem() {}

  swig_ruby_owntype GCItem::get_own() const
  {
    swig_ruby_owntype own = {0, 0};
    return own;
  }

  struct WXRB_EXPORT_FLAG GCItem_var
  {
    GCItem_var(GCItem *item = 0) : _item(item) {}

    GCItem_var& operator=(GCItem *item);

    ~GCItem_var()
    {
      delete _item;
    }

    GCItem *operator->() const
    {
      return _item;
    }

  private:
    GCItem *_item;
  };

  GCItem_var& GCItem_var::operator=(GCItem *item)
  {
    GCItem *tmp = _item;
    _item = item;
    delete tmp;
    return *this;
  }

  template <typename Type>
  struct GCItem_T : GCItem
  {
    GCItem_T(Type *ptr) : _ptr(ptr) {}

    virtual ~GCItem_T()
    {
      delete _ptr;
    }

  private:
    Type *_ptr;
  };

  struct WXRB_EXPORT_FLAG GCItem_Object : GCItem
  {
    GCItem_Object(swig_ruby_owntype own) : _own(own) {}

    virtual ~GCItem_Object() {}

    swig_ruby_owntype get_own() const
    {
      return _own;
    }

  private:
    swig_ruby_owntype _own;
  };

  template <typename Type>
  struct GCArray_T : GCItem
  {
    GCArray_T(Type *ptr) : _ptr(ptr) {}

    virtual ~GCArray_T()
    {
      delete[] _ptr;
    }

  private:
    Type *_ptr;
  };

  /* body args */
  struct body_args
  {
    VALUE recv;
    ID id;
    int argc;
    VALUE *argv;
  };

  /* Base class for director exceptions */
  class WXRB_EXPORT_FLAG DirectorException : public std::exception
  {
  protected:
    VALUE swig_error;
    std::string swig_msg;
  protected:
    DirectorException(VALUE error) : swig_error(error) {}

    DirectorException(VALUE error, const char *hdr, const char *msg ="");

    void setup_error(VALUE error);

  public:
    virtual ~DirectorException() throw();

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

  DirectorException::DirectorException(VALUE error, const char *hdr, const char *msg)
    : swig_msg(hdr)
  {
    if (msg[0])
    {
      swig_msg += " ";
      swig_msg += msg;
    }
    this->setup_error(error);
  }

  DirectorException::~DirectorException() throw()
  {}


  void DirectorException::setup_error(VALUE error)
  {
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

  /* Type mismatch in the return value from a Ruby method call */
  class WXRB_EXPORT_FLAG DirectorTypeMismatchException : public DirectorException
  {
  public:
    DirectorTypeMismatchException(VALUE error, const char *msg="")
      : DirectorException(error, "SWIG director type mismatch", msg)
    {}

    DirectorTypeMismatchException(const char *msg="")
      : DirectorException(rb_eTypeError, "SWIG director type mismatch", msg)
    {}

    DirectorTypeMismatchException(VALUE self, const char *method, VALUE error, const char *msg="");

    static inline void raise(VALUE error, const char *msg)
    {
      throw DirectorTypeMismatchException(error, msg);
    }

    static inline void raise(const char *msg)
    {
      throw DirectorTypeMismatchException(msg);
    }

    static inline void raise(VALUE self, const char* method, VALUE error, const char *msg)
    {
      throw DirectorTypeMismatchException(self, method, error, msg);
    }
  };


  DirectorTypeMismatchException::DirectorTypeMismatchException(VALUE self, const char *method, VALUE error, const char *msg)
    : DirectorException(Qnil)
  {
    this->swig_msg = "SWIG director type mismatch ";
    this->swig_msg += msg;
    this->swig_msg += " returned from ";
    this->swig_msg += rb_class2name(CLASS_OF(self));
    this->swig_msg += "#";
    this->swig_msg += method;
    this->setup_error(rb_eTypeError);
  }

  /* Any Ruby exception that occurs during a director method call */
  class WXRB_EXPORT_FLAG DirectorMethodException : public DirectorException
  {
  public:
    DirectorMethodException(VALUE error)
      : DirectorException(error)
    {}

    DirectorMethodException(const char *msg = "")
      : DirectorException(rb_eRuntimeError, "SWIG director method error.", msg)
    {}

    static void raise(VALUE error)
    {
      throw DirectorMethodException(error);
    }
  };

  /* Attempted to call a pure virtual method via a director method */
  class WXRB_EXPORT_FLAG DirectorPureVirtualException : public DirectorException
  {
  public:
    DirectorPureVirtualException(const char *msg = "")
      : DirectorException(rb_eRuntimeError, "SWIG director pure virtual method called", msg)
    {}

    static void raise(const char *msg)
    {
      throw DirectorPureVirtualException(msg);
    }
  };

  /* Simple thread abstraction for pthreads on win32 */
#ifdef __THREAD__
# define __PTHREAD__
# if defined(_WIN32) || defined(__WIN32__)
#  define pthread_mutex_lock EnterCriticalSection
#  define pthread_mutex_unlock LeaveCriticalSection
#  define pthread_mutex_t CRITICAL_SECTION
#  define SWIG_MUTEX_INIT(var) var
# else
#  include <pthread.h>
#  define SWIG_MUTEX_INIT(var) var = PTHREAD_MUTEX_INITIALIZER
# endif
#endif

#ifdef  __PTHREAD__
  struct Guard
  {
    pthread_mutex_t *_mutex;

    Guard(pthread_mutex_t &mutex) : _mutex(&mutex)
    {
      pthread_mutex_lock(_mutex);
    }

    ~Guard()
    {
      pthread_mutex_unlock(_mutex);
    }
  };
# define SWIG_GUARD(mutex) Guard _guard(mutex)
#else
# define SWIG_GUARD(mutex)
#endif

  /* director base class */
  class WXRB_EXPORT_FLAG Director
  {
  private:
    /* pointer to the wrapped Ruby object */
    VALUE swig_self;
    /* flag indicating whether the object is owned by Ruby or c++ */
    mutable bool swig_disown_flag;

  public:
    /* wrap a Ruby object. */
    Director(VALUE self);

    /* discard our reference at destruction */
    virtual ~Director();

    /* return a pointer to the wrapped Ruby object */
    VALUE swig_get_self() const
    {
      return swig_self;
    }

    /* acquire ownership of the wrapped Ruby object (the sense of "disown" is from Ruby) */
    void swig_disown() const
    {
      if (!swig_disown_flag)
      {
        swig_disown_flag = true;
      }
    }

  /* ownership management */
  private:
    typedef std::map<void *, GCItem_var> swig_ownership_map;
    mutable swig_ownership_map swig_owner;
#ifdef __PTHREAD__
    static pthread_mutex_t swig_mutex_own;
#endif

  public:
    template <typename Type>
    void swig_acquire_ownership_array(Type *vptr) const
    {
      if (vptr)
      {
        SWIG_GUARD(swig_mutex_own);
        swig_owner[vptr] = new GCArray_T<Type>(vptr);
      }
    }

    template <typename Type>
    void swig_acquire_ownership(Type *vptr)  const
    {
      if (vptr)
      {
        SWIG_GUARD(swig_mutex_own);
        swig_owner[vptr] = new GCItem_T<Type>(vptr);
      }
    }

    void swig_acquire_ownership_obj(void *vptr, swig_ruby_owntype own) const;

    swig_ruby_owntype swig_release_ownership(void *vptr) const;
  };

  Director::Director(VALUE self)
    : swig_self(self), swig_disown_flag(false)
  {}

  /* discard our reference at destruction */
  Director::~Director()
  {}

  void Director::swig_acquire_ownership_obj(void *vptr, swig_ruby_owntype own) const
  {
    if (vptr && own.datafree)
    {
      SWIG_GUARD(swig_mutex_own);
      swig_owner[vptr] = new GCItem_Object(own);
    }
  }

  swig_ruby_owntype Director::swig_release_ownership(void *vptr) const
  {
    swig_ruby_owntype own = {0, 0};
    if (vptr)
    {
      SWIG_GUARD(swig_mutex_own);
      swig_ownership_map::iterator iter = swig_owner.find(vptr);
      if (iter != swig_owner.end())
      {
        own.datafree = iter->second->get_own().datafree;
        swig_owner.erase(iter);
      }
    }
    return own;
  }

}
