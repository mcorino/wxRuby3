// Copyright (c) 2023 M.J.N. Corino, The Netherlands
//
// This software is released under the MIT license.

/*
 * WxRuby3 wxRubyClientData class
 */

#ifndef _WXRUBY_CLIENT_DATA_H
#define _WXRUBY_CLIENT_DATA_H

#include <wx/clntdata.h>

class WXRUBY_EXPORT wxRubyClientData;

WXRUBY_EXPORT void wxRuby_RegisterClientData(wxRubyClientData* pcd);
WXRUBY_EXPORT void wxRuby_UnregisterClientData(wxRubyClientData* pcd);

class WXRUBY_EXPORT wxRubyClientData : public wxClientData
{
public:
  wxRubyClientData() : rb_data(Qnil) { }
  wxRubyClientData (VALUE data) : rb_data(data) { wxRuby_RegisterClientData(this); }
  virtual ~wxRubyClientData () { wxRuby_UnregisterClientData(this); }
  VALUE GetData() const { return rb_data; }
private:
  VALUE rb_data;
};

class WXRUBY_EXPORT wxRubyUserData;

WXRUBY_EXPORT void wxRuby_RegisterUserData(wxRubyUserData* pud);
WXRUBY_EXPORT void wxRuby_UnregisterUserData(wxRubyUserData* pud);

class WXRUBY_EXPORT wxRubyUserData : public wxObject
{
public:
  wxRubyUserData() : rb_data(Qnil) { }
  wxRubyUserData (VALUE data) : rb_data(data) { wxRuby_RegisterUserData(this); }
  virtual ~wxRubyUserData () { wxRuby_UnregisterUserData(this); }
  VALUE GetData() const { return rb_data; }
private:
  VALUE rb_data;

  wxDECLARE_NO_COPY_CLASS(wxRubyUserData);
};

#endif /* _WXRUBY_CLIENT_DATA_H */
