// Copyright (c) 2023 M.J.N. Corino, The Netherlands
//
// This software is released under the MIT license.

/*
 * WxRuby3 wxRubyValidator class
 */

#ifndef _WXRUBY_VALIDATOR_H
#define _WXRUBY_VALIDATOR_H

#include "wxruby-ValidatorBinding.h"

class WXRUBY_EXPORT wxRubyValidator : public wxValidator, public wxRubyValidatorBinding
{
public:
  wxRubyValidator ();
  wxRubyValidator (const wxRubyValidator&);
  virtual ~wxRubyValidator ();

  virtual wxObject* Clone() const override;

  virtual void SetWindow(wxWindow *win) override;

  virtual bool TransferFromWindow () override;
  virtual bool TransferToWindow () override;

protected:
  static WxRuby_ID do_transfer_from_window_id;
  static WxRuby_ID do_transfer_to_window_id;
  static WxRuby_ID clone_id;

  virtual VALUE DoTransferFromWindow();
  virtual bool DoTransferToWindow(VALUE data);
};

#endif /* _WXRUBY_VALIDATOR_HASH_H */
