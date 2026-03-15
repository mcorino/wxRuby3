// Copyright (c) 2023 M.J.N. Corino, The Netherlands
//
// This software is released under the MIT license.

/*
  A shared pointer class to wrap wxSharedPtr for derived classes and allowing implicit
  conversion to wxSharedPtr without loosing reference counting and implicit down casting.
*/
#include <wx/sharedptr.h>

template <class T, class Base = T>
class WxRubySharedPtr
{
public:
  typedef T* ptr_t;
  typedef wxSharedPtr<Base> shared_ptr_t;

  explicit WxRubySharedPtr( T* ptr = nullptr )
    : shared_ptr_(ptr)
  {
  }

  WxRubySharedPtr(const WxRubySharedPtr& other)
    : shared_ptr_(other.get_shared())
  {}

  WxRubySharedPtr(WxRubySharedPtr&& other)
    : shared_ptr_(std::move (other.get_shared()))
  {}

  template<typename _Tp1, typename = typename
    std::enable_if<std::is_convertible<typename _Tp1::ptr_t, T*>::value>::type>
  WxRubySharedPtr(const _Tp1& other)
    : shared_ptr_(other.get_shared())
  {}

  template<typename _Tp1, typename = typename
    std::enable_if<std::is_convertible<typename _Tp1::ptr_t, T*>::value>::type>
  WxRubySharedPtr(_Tp1&& other)
    : shared_ptr_(std::move(other.get_shared()))
  {}

  WxRubySharedPtr& operator=(const WxRubySharedPtr& other)
  {
    this->shared_ptr_ = other.get_shared();
    return *this;
  }

  WxRubySharedPtr& operator=( T* ptr )
  {
    this->shared_ptr_ = ptr;
    return *this;
  }

  template<typename _Tp1, typename = typename
    std::enable_if<std::is_convertible<typename _Tp1::ptr_t, T*>::value>::type>
  WxRubySharedPtr& operator=(const _Tp1& other)
  {
    this->shared_ptr_ = other.get_shared();
    return *this;
  }

  T* operator->()
  {
    return const_cast<T*> (this->_get());
  }

  const T* operator->() const
  {
    return this->_get();
  }

  const T* get() const
  {
    return this->_get();
  }

  void reset( T* ptr = nullptr )
  {
    this->shared_ptr_.reset(ptr);
  }

  shared_ptr_t get_shared() const { return this->shared_ptr_; }

  operator shared_ptr_t() const { return this->get_shared(); }

private:

  const T* _get() const
  {
    return dynamic_cast<const T*> (this->shared_ptr_.get());
  }

  shared_ptr_t shared_ptr_;
};
