// Copyright (c) 2023 M.J.N. Corino, The Netherlands
//
// This software is released under the MIT license.

#ifndef WXRUBY_EXPORT
#define WXRUBY_EXPORT WXRB_EXPORT_FLAG
#endif

#include "wxruby-runtime.h"
#include "wxruby-ClientData.h"

#include <set>

static bool __s_RubyClientDataMarker_Registered = false;
static bool __s_RubyUserDataMarker_Registered = false;

static const std::string WXRUBY_CLIENT_DATA = { "WXRUBY_CLIENT_DATA" };
static const std::string WXRUBY_USER_DATA = { "WXRUBY_USER_DATA" };

static void wxRuby_GC_mark_ClientData(const TGCTrackingValueMap& values)
{
  for (const auto& ti : values)
  {
    wxRubyClientData* pcd = static_cast<wxRubyClientData*> (ti.first);
    rb_gc_mark(pcd->GetData());
  }
}

static void wxRuby_GC_mark_UserData(const TGCTrackingValueMap& values)
{
  for (const auto& ti : values)
  {
    wxRubyUserData* pud = static_cast<wxRubyUserData*> (ti.first);
    rb_gc_mark(pud->GetData());
  }
}

WXRB_EXPORT_FLAG void wxRuby_RegisterClientData(wxRubyClientData* pcd)
{
  if (!__s_RubyClientDataMarker_Registered)
  {
    wxRuby_RegisterTrackingCategory(WXRUBY_CLIENT_DATA, wxRuby_GC_mark_ClientData, true);
    __s_RubyClientDataMarker_Registered = true;
  }
  wxRuby_RegisterCategoryValue(WXRUBY_CLIENT_DATA, pcd, Qnil);
}

WXRB_EXPORT_FLAG void wxRuby_RegisterUserData(wxRubyUserData* pud)
{
  if (!__s_RubyUserDataMarker_Registered)
  {
    wxRuby_RegisterTrackingCategory(WXRUBY_USER_DATA, wxRuby_GC_mark_UserData, true);
    __s_RubyUserDataMarker_Registered = true;
  }
  wxRuby_RegisterCategoryValue(WXRUBY_USER_DATA, pud, Qnil);
}

static ID client_data_unlinked_id()
{
  static ID __s_client_data_unlinked_id {};
  if (__s_client_data_unlinked_id == ID())
  {
    __s_client_data_unlinked_id = rb_intern("client_data_unlinked");
  }
  return __s_client_data_unlinked_id;
}

WXRB_EXPORT_FLAG void wxRuby_UnregisterClientData(wxRubyClientData* pcd)
{
  VALUE rbcd = pcd->GetData();
  wxRuby_UnregisterCategoryValue(WXRUBY_CLIENT_DATA, pcd);
  if (!NIL_P(rbcd) && rb_respond_to(rbcd, client_data_unlinked_id()))
  {
    wxRuby_Funcall(rbcd, client_data_unlinked_id(), 0);
  }
}

WXRB_EXPORT_FLAG void wxRuby_UnregisterUserData(wxRubyUserData* pud)
{
  VALUE rbud = pud->GetData();
  wxRuby_UnregisterCategoryValue(WXRUBY_USER_DATA, pud);
  if (!NIL_P(rbud) && rb_respond_to(rbud, client_data_unlinked_id()))
  {
    wxRuby_Funcall(rbud, client_data_unlinked_id(), 0);
  }
}
