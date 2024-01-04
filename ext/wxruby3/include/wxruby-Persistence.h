// Copyright (c) 2023 M.J.N. Corino, The Netherlands
//
// This software is released under the MIT license.

/*
 * WxRuby3 persistence classes
 */

#ifndef _WXRUBY_PERSISTENCE_HASH_H
#define _WXRUBY_PERSISTENCE_HASH_H

#include <wx/persist.h>
#include <wx/config.h>

#include <map>

/*
  This class serves as a base for any Ruby defined persistence manager in order to provide
  customized save and restore methods for Ruby values but also as a replacement for the
  default global persistence manager instance.
 */
class WxRubyPersistenceManager : public wxPersistenceManager
{
private:
  typedef std::map<VALUE, VALUE> rb_object_to_rb_po_map_t;
  rb_object_to_rb_po_map_t rb_object_po_map_;

public:
  WxRubyPersistenceManager() : wxPersistenceManager() {}

  bool SaveRubyValue(const wxPersistentObject& who, const wxString& name, VALUE value);

  VALUE RestoreRubyValue(const wxPersistentObject& who, const wxString& name);


  bool DoSaveRubyValue(const wxPersistentObject& who, const wxString& name, VALUE value);

  VALUE DoRestoreRubyValue(const wxPersistentObject& who, const wxString& name);

  void RegisterRbPO(VALUE rb_obj, VALUE rb_po)
  {
    rb_object_po_map_[rb_obj] = rb_po;
  }

  VALUE FindRbPO(VALUE rb_obj)
  {
    VALUE rb_po = Qnil;
    if (rb_object_po_map_.count(rb_obj) > 0)
    {
      rb_po = rb_object_po_map_[rb_obj];
    }
    return rb_po;
  }

  VALUE UnregisterRbPO(VALUE rb_obj)
  {
    VALUE rb_po = Qnil;
    if (rb_object_po_map_.count(rb_obj) > 0)
    {
      rb_po = rb_object_po_map_[rb_obj];
      rb_object_po_map_.erase(rb_obj);
    }
    return rb_po;
  }

  void GC_markPO();

  static void UnregisterPersistentObject(VALUE rb_obj);
};

class WxRubyPersistentObject : public wxPersistentObject
{
public:
  virtual ~WxRubyPersistentObject();
protected:
  WxRubyPersistentObject(VALUE rb_obj);
};

#endif /* _WXRUBY_PERSISTENCE_HASH_H */
