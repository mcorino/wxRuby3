// Copyright (c) 2023 M.J.N. Corino, The Netherlands
//
// This software is released under the MIT license.

#ifndef WXRUBY_EXPORT
#define WXRUBY_EXPORT WXRB_EXPORT_FLAG
#endif

#include "wxruby-ClientData.h"

#include <set>

static std::set<wxRubyClientData*> __s_WxRubyClientDataSet;

WXRB_EXPORT_FLAG void wxRuby_RegisterClientData(wxRubyClientData* pcd)
{
  __s_WxRubyClientDataSet.insert(pcd);
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
  __s_WxRubyClientDataSet.erase(pcd);
  if (!NIL_P(rbcd) && rb_respond_to(rbcd, client_data_unlinked_id()))
  {
    wxRuby_Funcall(rbcd, client_data_unlinked_id(), 0);
  }
}

static void wxRuby_GC_mark_ClientData()
{
  for (wxRubyClientData* pcd : __s_WxRubyClientDataSet)
    rb_gc_mark(pcd->GetData());
}

typedef void (*WXRBMarkFunction)();
WXRUBY_EXPORT void wxRuby_AppendMarker(WXRBMarkFunction marker);
