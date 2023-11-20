// Copyright (c) 2023 M.J.N. Corino, The Netherlands
//
// This software is released under the MIT license.

/*
 * WxRuby3 wxRubyValidatorBinding class
 */

#ifndef _WXRUBY_VALIDATOR_BINDING_H
#define _WXRUBY_VALIDATOR_BINDING_H

class WXRUBY_EXPORT wxRubyValidatorBinding
{
public:
  wxRubyValidatorBinding ()
    : self_(Qnil)
    , on_transfer_from_win_proc_(Qnil)
    , on_transfer_to_win_proc_(Qnil)
  {}

  void SetOnTransferFromWindow(VALUE proc)
  {
    this->on_transfer_from_win_proc_ = proc;
  }
  void SetOnTransferToWindow(VALUE proc)
  {
    this->on_transfer_to_win_proc_ = proc;
  }

  VALUE DoOnTransferToWindow();
  bool DoOnTransferFromWindow(VALUE data);

  bool OnTransferFromWindow(VALUE data);
  VALUE OnTransferToWindow();

  void GC_Mark()
  {
    rb_gc_mark(this->on_transfer_from_win_proc_);
    rb_gc_mark(this->on_transfer_to_win_proc_);
  }

protected:
  static WxRuby_ID do_on_transfer_from_window_id;
  static WxRuby_ID do_on_transfer_to_window_id;
  static WxRuby_ID call_id;

  wxRubyValidatorBinding (const wxRubyValidatorBinding& vb)
    : self_(Qnil)
    , on_transfer_from_win_proc_(vb.on_transfer_from_win_proc_)
    , on_transfer_to_win_proc_(vb.on_transfer_to_win_proc_)
  {}

  void CopyBindings(const wxRubyValidatorBinding* val_bind);

  virtual VALUE get_self() = 0;

  VALUE self_;

private:
  VALUE on_transfer_from_win_proc_;
  VALUE on_transfer_to_win_proc_;
};

#endif /* #define _WXRUBY_VALIDATOR_BINDING_H */
