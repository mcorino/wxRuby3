/*
 * WxRuby3 wxRbHashConfig class
 * Copyright (c) M.J.N. Corino, The Netherlands
 */

#ifndef _WXRUBY_CONFIG_RB_HASH_H
#define _WXRUBY_CONFIG_RB_HASH_H

#include <wx/config.h>
#include <ruby/version.h>

VALUE rb_hash_delete (VALUE hash, VALUE key);

#if RUBY_API_VERSION_MAJOR<3 && RUBY_API_VERSION_MINOR<7
typedef int (*rb_foreach_func)(ANYARGS);
#else
typedef int (*rb_foreach_func)(VALUE, VALUE, VALUE);
#endif
#define FOREACH_FUNC(x) reinterpret_cast<rb_foreach_func>((void*)&(x))

inline bool rb_hash_includes(VALUE hash, VALUE key)
{
  return (rb_hash_lookup2(hash, key, Qundef) != Qundef);
}

struct RbCfgCounter
{
  bool groups;
  bool recursive;
  size_t count;
};

static int wxrb_CountConfig(VALUE key, VALUE value, VALUE rbCounter)
{
  RbCfgCounter* counter;
  Data_Get_Struct(rbCounter, RbCfgCounter, counter);
  if (TYPE(value) == T_HASH)
  {
    if (counter->groups)
      ++counter->count;
    if (counter->recursive)
      rb_hash_foreach(value, FOREACH_FUNC(wxrb_CountConfig), rbCounter);
  }
  else
  {
    if (!counter->groups)
      ++counter->count;
  }
  return ST_CONTINUE;
}

class wxRbHashConfig : public wxConfigBase
{
public:
  static WxRuby_ID split_ID;
  static wxString cfgSepStr;
  static WxRuby_ID keys_ID;
  static WxRuby_ID to_s_ID;
  static WxRuby_ID to_i_ID;
  static WxRuby_ID to_f_ID;

  // ctor & dtor
  wxRbHashConfig(VALUE cfgHash)
    : wxConfigBase(wxTheApp ? wxTheApp->GetAppName() : wxString())
    , m_cfgHash(cfgHash)
    , m_cfgGroup(cfgHash)
    , m_cfgGroupKeys(Qnil)
  {
    SetRootPath();
  }

  virtual ~wxRbHashConfig() {}

  // Ruby GC marking
  void GC_Mark() const
  {
    rb_gc_mark(m_cfgHash);
    if (!NIL_P(m_cfgGroupKeys)) rb_gc_mark(m_cfgGroupKeys);
    // m_cfgGroup is always either m_cfgHash itself or an entry of this and so does
    // not require separate marking
  }

  // Get wrapped Ruby Hash
  VALUE GetHash() const { return m_cfgHash; }

  // implement inherited pure virtual functions
  virtual void SetPath(const wxString& strPath) override { DoSetPath(strPath, true /* create missing components */); }
  virtual const wxString& GetPath() const override { return m_strPath; }

  virtual bool GetFirstGroup(wxString& str, long& lIndex) const override
  {
      lIndex = 0;
      return GetNextGroup(str, lIndex);
  }

  virtual bool GetNextGroup (wxString& str, long& lIndex) const override
  {
    if (NIL_P(m_cfgGroupKeys))
    {
      wxRbHashConfig* self = const_cast<wxRbHashConfig*> (this);
      self->m_cfgGroupKeys = rb_funcall(m_cfgGroup, keys_ID(), 0);
    }

    if (lIndex < RARRAY_LEN(m_cfgGroupKeys))
    {
      for (long lix=lIndex; lix < RARRAY_LEN(m_cfgGroupKeys) ;)
      {
        VALUE rbEntry = rb_ary_entry(m_cfgGroupKeys, lix++);
        VALUE rbVal = rb_hash_aref(m_cfgGroup, rbEntry);
        if (TYPE(rbVal) == T_HASH)
        {
          lIndex = lix;
          str = RSTR_TO_WXSTR(rbEntry);
          return true;
        }
      }
    }
    return false;
  }

  virtual bool GetFirstEntry(wxString& str, long& lIndex) const override
  {
      lIndex = 0;
      return GetNextEntry(str, lIndex);
  }

  virtual bool GetNextEntry (wxString& str, long& lIndex) const override
  {
    if (NIL_P(m_cfgGroupKeys))
    {
      wxRbHashConfig* self = const_cast<wxRbHashConfig*> (this);
      self->m_cfgGroupKeys = rb_funcall(m_cfgGroup, keys_ID(), 0);
    }

    if (lIndex < RARRAY_LEN(m_cfgGroupKeys))
    {
      for (long lix=lIndex; lix < RARRAY_LEN(m_cfgGroupKeys) ;)
      {
        VALUE rbEntry = rb_ary_entry(m_cfgGroupKeys, lix++);
        VALUE rbVal = rb_hash_aref(m_cfgGroup, rbEntry);
        if (TYPE(rbVal) != T_HASH)
        {
          lIndex = lix;
          str = RSTR_TO_WXSTR(rbEntry);
          return true;
        }
      }
    }
    return false;
  }

  virtual size_t GetNumberOfEntries(bool bRecursive = false) const override
  {
    RbCfgCounter counter = {false, bRecursive, 0};
    void* ptr = &counter;
    VALUE rbCounter = Data_Wrap_Struct(rb_cObject, 0, 0, ptr);
    rb_hash_foreach(m_cfgGroup, FOREACH_FUNC(wxrb_CountConfig), rbCounter);
    return counter.count;
  }

  virtual size_t GetNumberOfGroups(bool bRecursive = false) const override
  {
    RbCfgCounter counter = {true, bRecursive, 0};
    void* ptr = &counter;
    VALUE rbCounter = Data_Wrap_Struct(rb_cObject, 0, 0, ptr);
    rb_hash_foreach(m_cfgGroup, FOREACH_FUNC(wxrb_CountConfig), rbCounter);
    return counter.count;
  }

  virtual bool HasGroup(const wxString& strName) const override
  {
    // special case: DoSetPath("") does work as it's equivalent to DoSetPath("/")
    // but there is no group with empty name so treat this separately
    if ( strName.empty() )
        return false;

    const wxString pathOld = GetPath();

    // path is the part before the last "/"
    wxString path = strName.BeforeLast(wxCONFIG_PATH_SEPARATOR);

    // except in the special case of "/group" when there is nothing before "/"
    if ( path.empty() && *strName.c_str() == wxCONFIG_PATH_SEPARATOR )
    {
        path = wxCONFIG_PATH_SEPARATOR;
    }

    // check if the path exists as well as the group at that path
    wxRbHashConfig *self = const_cast<wxRbHashConfig *>(this);
    const bool rc =
      self->DoSetPath(path, false /* don't create missing components */) &&
      self->hasGroup(strName.AfterLast(wxCONFIG_PATH_SEPARATOR));

    self->SetPath(pathOld);

    return rc;
  }

  virtual bool HasEntry(const wxString& entry) const override
  {
    // path is the part before the last "/"
    wxString path = entry.BeforeLast(wxCONFIG_PATH_SEPARATOR);

    // except in the special case of "/keyname" when there is nothing before "/"
    if ( path.empty() && *entry.c_str() == wxCONFIG_PATH_SEPARATOR )
    {
        path = wxCONFIG_PATH_SEPARATOR;
    }

    // change to the path of the entry if necessary and remember the old path
    // to restore it later
    wxString pathOld;
    wxRbHashConfig * const self = const_cast<wxRbHashConfig *>(this);
    if ( !path.empty() )
    {
        pathOld = GetPath();
        if ( pathOld.empty() )
            pathOld = wxCONFIG_PATH_SEPARATOR;

        if ( !self->DoSetPath(path, false /* don't create if doesn't exist */) )
        {
            return false;
        }
    }

    // check if the entry exists in this group
    const bool exists = hasEntry(entry.AfterLast(wxCONFIG_PATH_SEPARATOR));

    // restore the old path if we changed it above
    if ( !pathOld.empty() )
    {
        self->SetPath(pathOld);
    }

    return exists;
  }

  virtual EntryType GetEntryType(const wxString& entry) const override
  {
    // path is the part before the last "/"
    wxString path = entry.BeforeLast(wxCONFIG_PATH_SEPARATOR);

    // except in the special case of "/keyname" when there is nothing before "/"
    if ( path.empty() && *entry.c_str() == wxCONFIG_PATH_SEPARATOR )
    {
        path = wxCONFIG_PATH_SEPARATOR;
    }

    // change to the path of the entry if necessary and remember the old path
    // to restore it later
    wxString pathOld;
    wxRbHashConfig * const self = const_cast<wxRbHashConfig *>(this);
    if ( !path.empty() )
    {
        pathOld = GetPath();
        if ( pathOld.empty() )
            pathOld = wxCONFIG_PATH_SEPARATOR;

        if ( !self->DoSetPath(path, false /* don't create if doesn't exist */) )
        {
            return Type_Unknown;
        }
    }

    // check if the entry exists in this group
    VALUE rbValue;
    const bool exists = getEntry(entry.AfterLast(wxCONFIG_PATH_SEPARATOR), rbValue);

    // restore the old path if we changed it above
    if ( !pathOld.empty() )
    {
        self->SetPath(pathOld);
    }

    if (exists && TYPE(rbValue) != T_HASH)
    {
      switch(TYPE(rbValue))
      {
        case T_STRING: return Type_String;
        case T_FLOAT: return Type_Float;
        case T_FIXNUM:
        case T_BIGNUM: return Type_Integer;
        case T_TRUE:
        case T_FALSE: return Type_Boolean;
      }
    }

    return Type_Unknown;
  }

  virtual bool Flush(bool bCurrentOnly = false) override { return true; }

  virtual bool RenameEntry(const wxString& oldName, const wxString& newName) override
  {
    wxASSERT_MSG( oldName.find(wxCONFIG_PATH_SEPARATOR) == wxString::npos,
                   wxT("RenameEntry(): paths are not supported") );

    // check that the entry exists
    VALUE rbEntryValue;
    if ( !getEntry(oldName, rbEntryValue) )
        return false;

    // check that the new entry doesn't already exist
    if ( hasEntry(newName) )
        return false;

    // delete the old entry, create the new one
    rb_hash_delete(m_cfgGroup, WXSTR_TO_RSTR(oldName));
    rb_hash_aset(m_cfgGroup, WXSTR_TO_RSTR(newName), rbEntryValue);
    m_cfgGroupKeys = Qnil; // reset

    return true;
  }

  virtual bool RenameGroup(const wxString& oldName, const wxString& newName) override
  {
    wxASSERT_MSG( oldName.find(wxCONFIG_PATH_SEPARATOR) == wxString::npos,
                   wxT("RenameGroup(): paths are not supported") );

    // check that the group exists
    VALUE rbGroup;
    if ( !getGroup(oldName, rbGroup) )
        return false;

    // check that the new group doesn't already exist
    if ( hasGroup(newName) )
        return false;

    // delete the old group entry, create the new one
    rb_hash_delete(m_cfgGroup, WXSTR_TO_RSTR(oldName));
    rb_hash_aset(m_cfgGroup, WXSTR_TO_RSTR(newName), rbGroup);
    m_cfgGroupKeys = Qnil; // reset

    return true;
  }

  virtual bool DeleteEntry(const wxString& key, bool bGroupIfEmptyAlso = true) override
  {
    bool deleteGroup = false;
    wxString grpPath;
    {
      wxConfigPathChanger path(this, key);

      VALUE rbEntry = WXSTR_TO_RSTR(path.Name());
      if ( !rb_hash_includes(m_cfgGroup, rbEntry) )
        return false;
      rb_hash_delete(m_cfgGroup, rbEntry);

      if ( bGroupIfEmptyAlso && RHASH_SIZE(m_cfgGroup) == 0 )
      {
        if ( m_cfgHash != m_cfgGroup )
        {
          deleteGroup = true;
          grpPath = m_strPath;
        }
        //else: never delete the root group
      }
    }
    // here wxConfigPathChanger has reverted to the original path

    if (deleteGroup)
    {
      DeleteGroup(grpPath);
    }

    return true;
  }

  virtual bool DeleteGroup(const wxString& szKey) override
  {
    wxConfigPathChanger path(this, RemoveTrailingSeparator(szKey));

    VALUE rbGrpName = WXSTR_TO_RSTR(path.Name());
    if ( !rb_hash_includes(m_cfgGroup, rbGrpName) )
      return false;
    rb_hash_delete(m_cfgGroup, rbGrpName);

    path.UpdateIfDeleted();

    return true;
  }

  virtual bool DeleteAll() override
  {
    rb_hash_clear(m_cfgHash);
    SetRootPath();
    return true;
  }

protected:
  virtual bool DoReadString(const wxString& key, wxString *pStr) const override
  {
    wxConfigPathChanger path(this, key);

    VALUE rbKey = WXSTR_TO_RSTR(path.Name());
    if (rb_hash_includes(m_cfgGroup, rbKey) == Qfalse)
    {
        return false;
    }

    VALUE rbEntry = rb_hash_aref(m_cfgGroup, rbKey);

    if (TYPE(rbEntry) == T_HASH)
      return false;

    if (TYPE(rbEntry) == T_STRING)
      *pStr = RSTR_TO_WXSTR(rbEntry);
    else
    {
      VALUE s = rb_funcall(rbEntry, to_s_ID(), 0);
      *pStr = RSTR_TO_WXSTR(s);
    }

    return true;
  }

  virtual bool DoReadLong(const wxString& key, long *pl) const override
  {
    wxConfigPathChanger path(this, key);

    VALUE rbKey = WXSTR_TO_RSTR(path.Name());
    if (rb_hash_includes(m_cfgGroup, rbKey) == Qfalse)
    {
        return false;
    }

    VALUE rbEntry = rb_hash_aref(m_cfgGroup, rbKey);

    if (TYPE(rbEntry) == T_HASH)
      return false;

    if (TYPE(rbEntry) == T_FIXNUM || TYPE(rbEntry) == T_BIGNUM)
    {
      *pl = NUM2LONG(rbEntry);
      return true;
    }
    else
    {
      bool ex = false;
      VALUE rbVal = wxRuby_Funcall(ex, rbEntry, to_i_ID(), 0);
      if (!ex)
        *pl = NUM2LONG(rbVal);
      return !ex;
    }
  }

#ifdef wxHAS_LONG_LONG_T_DIFFERENT_FROM_LONG
  virtual bool DoReadLongLong(const wxString& key, wxLongLong_t *pll) const
  {
    wxConfigPathChanger path(this, key);

    VALUE rbKey = WXSTR_TO_RSTR(path.Name());
    if (rb_hash_includes(m_cfgGroup, rbKey) == Qfalse)
    {
        return false;
    }

    VALUE rbEntry = rb_hash_aref(m_cfgGroup, rbKey);

    if (TYPE(rbEntry) == T_HASH)
      return false;

    if (TYPE(rbEntry) == T_FIXNUM || TYPE(rbEntry) == T_BIGNUM)
    {
      *pll = NUM2LL(rbEntry);
      return true;
    }
    else
    {
      bool ex = false;
      VALUE rbVal = wxRuby_Funcall(ex, rbEntry, to_i_ID(), 0);
      if (!ex)
        *pll = NUM2LL(rbVal);
      return !ex;
    }
  }
#endif // wxHAS_LONG_LONG_T_DIFFERENT_FROM_LONG

  virtual bool DoReadDouble(const wxString& key, double* val) const
  {
    wxConfigPathChanger path(this, key);

    VALUE rbKey = WXSTR_TO_RSTR(path.Name());
    if (rb_hash_includes(m_cfgGroup, rbKey) == Qfalse)
    {
        return false;
    }

    VALUE rbEntry = rb_hash_aref(m_cfgGroup, rbKey);

    if (TYPE(rbEntry) == T_HASH)
      return false;

    if (TYPE(rbEntry) == T_FLOAT)
    {
      *val = NUM2DBL(rbEntry);
      return true;
    }
    else
    {
      bool ex = false;
      VALUE rbVal = wxRuby_Funcall(ex, rbEntry, to_f_ID(), 0);
      if (!ex)
        *val = NUM2DBL(rbVal);
      return !ex;
    }
  }

  virtual bool DoReadBool(const wxString& key, bool* val) const
  {
    wxConfigPathChanger path(this, key);

    VALUE rbKey = WXSTR_TO_RSTR(path.Name());
    if (rb_hash_includes(m_cfgGroup, rbKey) == Qfalse)
    {
        return false;
    }

    VALUE rbEntry = rb_hash_aref(m_cfgGroup, rbKey);

    if (TYPE(rbEntry) == T_HASH)
      return false;

    if (TYPE(rbEntry) == T_TRUE || TYPE(rbEntry) == T_FALSE)
    {
      *val = rbEntry == Qtrue;
    }
    else if (TYPE(rbEntry) == T_FIXNUM || TYPE(rbEntry) == T_BIGNUM)
    {
      *val = NUM2LL(rbEntry) != 0;
    }
    else
    {
      return false;
    }
    return true;
  }

#if wxUSE_BASE64
  virtual bool DoReadBinary(const wxString& key, wxMemoryBuffer* buf) const override
  {
    wxCHECK_MSG( buf, false, wxT("null buffer") );

    wxString str;
    if ( !Read(key, &str) )
        return false;

    *buf = wxBase64Decode(str);
    return true;
  }
#endif // wxUSE_BASE64

  virtual bool DoWriteString(const wxString& key, const wxString& szValue) override
  {
    wxConfigPathChanger     path(this, key);
    wxString                strName = path.Name();

    if ( strName.empty() )
    {
            // setting the value of a group is an error

        wxASSERT_MSG( szValue.empty(), wxT("can't set value of a group!") );

        // ... except if it's empty in which case it's a way to force it's creation
    }
    else
    {
        // writing an entry check that the name is reasonable
        if ( strName[0u] == wxCONFIG_IMMUTABLE_PREFIX )
        {
            wxLogError( _("Config entry name cannot start with '%c'."),
                        wxCONFIG_IMMUTABLE_PREFIX);
            return false;
        }

        VALUE rbKey = WXSTR_TO_RSTR(strName);
        VALUE rbEntry = rb_hash_aref(m_cfgGroup, rbKey);
        if (TYPE(rbEntry) == T_HASH)
        {
          // do not allow to overwrite existing group entries
          wxLogError( _("Setting value for config entry '%s' would overwrite group."),
                      key);
          return false;
        }

        rb_hash_aset(m_cfgGroup, rbKey, WXSTR_TO_RSTR(szValue));
    }

    return true;
  }
  virtual bool DoWriteLong(const wxString& key, long lValue) override
  {
    wxConfigPathChanger     path(this, key);
    wxString                strName = path.Name();

    if ( strName.empty() )
    {
        // setting the value of a group is an error
        wxLogError( _("can't set value of a group!"));
        return false;
    }
    else
    {
        // writing an entry check that the name is reasonable
        if ( strName[0u] == wxCONFIG_IMMUTABLE_PREFIX )
        {
            wxLogError( _("Config entry name cannot start with '%c'."),
                        wxCONFIG_IMMUTABLE_PREFIX);
            return false;
        }

        VALUE rbKey = WXSTR_TO_RSTR(strName);
        VALUE rbEntry = rb_hash_aref(m_cfgGroup, rbKey);
        if (TYPE(rbEntry) == T_HASH)
        {
          // do not allow to overwrite existing group entries
          wxLogError( _("Setting value for config entry '%s' would overwrite group."),
                      key);
          return false;
        }

        rb_hash_aset(m_cfgGroup, rbKey, LONG2NUM(lValue));
    }

    return true;
  }

#ifdef wxHAS_LONG_LONG_T_DIFFERENT_FROM_LONG
  virtual bool DoWriteLongLong(const wxString& key, wxLongLong_t value)
  {
    wxConfigPathChanger     path(this, key);
    wxString                strName = path.Name();

    if ( strName.empty() )
    {
        // setting the value of a group is an error
        wxLogError( _("can't set value of a group!"));
        return false;
    }
    else
    {
        // writing an entry check that the name is reasonable
        if ( strName[0u] == wxCONFIG_IMMUTABLE_PREFIX )
        {
            wxLogError( _("Config entry name cannot start with '%c'."),
                        wxCONFIG_IMMUTABLE_PREFIX);
            return false;
        }

        VALUE rbKey = WXSTR_TO_RSTR(strName);
        VALUE rbEntry = rb_hash_aref(m_cfgGroup, rbKey);
        if (TYPE(rbEntry) == T_HASH)
        {
          // do not allow to overwrite existing group entries
          wxLogError( _("Setting value for config entry '%s' would overwrite group."),
                      key);
          return false;
        }

        rb_hash_aset(m_cfgGroup, rbKey, LL2NUM(value));
    }

    return true;
  }
#endif // wxHAS_LONG_LONG_T_DIFFERENT_FROM_LONG

  virtual bool DoWriteDouble(const wxString& key, double value)
  {
    wxConfigPathChanger     path(this, key);
    wxString                strName = path.Name();

    if ( strName.empty() )
    {
        // setting the value of a group is an error
        wxLogError( _("can't set value of a group!"));
        return false;
    }
    else
    {
        // writing an entry check that the name is reasonable
        if ( strName[0u] == wxCONFIG_IMMUTABLE_PREFIX )
        {
            wxLogError( _("Config entry name cannot start with '%c'."),
                        wxCONFIG_IMMUTABLE_PREFIX);
            return false;
        }

        VALUE rbKey = WXSTR_TO_RSTR(strName);
        VALUE rbEntry = rb_hash_aref(m_cfgGroup, rbKey);
        if (TYPE(rbEntry) == T_HASH)
        {
          // do not allow to overwrite existing group entries
          wxLogError( _("Setting value for config entry '%s' would overwrite group."),
                      key);
          return false;
        }

        rb_hash_aset(m_cfgGroup, rbKey, DBL2NUM(value));
    }

    return true;
  }

  virtual bool DoWriteBool(const wxString& key, bool value)
  {
    wxConfigPathChanger     path(this, key);
    wxString                strName = path.Name();

    if ( strName.empty() )
    {
        // setting the value of a group is an error
        wxLogError( _("can't set value of a group!"));
        return false;
    }
    else
    {
        // writing an entry check that the name is reasonable
        if ( strName[0u] == wxCONFIG_IMMUTABLE_PREFIX )
        {
            wxLogError( _("Config entry name cannot start with '%c'."),
                        wxCONFIG_IMMUTABLE_PREFIX);
            return false;
        }

        VALUE rbKey = WXSTR_TO_RSTR(strName);
        VALUE rbEntry = rb_hash_aref(m_cfgGroup, rbKey);
        if (TYPE(rbEntry) == T_HASH)
        {
          // do not allow to overwrite existing group entries
          wxLogError( _("Setting value for config entry '%s' would overwrite group."),
                      key);
          return false;
        }

        rb_hash_aset(m_cfgGroup, rbKey, value ? Qtrue : Qfalse);
    }

    return true;
  }

#if wxUSE_BASE64
  virtual bool DoWriteBinary(const wxString& key, const wxMemoryBuffer& buf) override
  {
    return Write(key, wxBase64Encode(buf));
  }
#endif // wxUSE_BASE64

private:

  bool getEntry(const wxString& entry, VALUE& rbValue) const
  {
    if (NIL_P(m_cfgGroup)) return false;

    VALUE rbEntry = WXSTR_TO_RSTR(entry);
    if (rb_hash_includes(m_cfgGroup, rbEntry))
    {
      VALUE rbVal = rb_hash_aref(m_cfgGroup, rbEntry);
      if (TYPE(rbVal) != T_HASH)
      {
        rbValue = rbVal;
        return true;
      }
    }
    return false;
  }

  bool hasEntry(const wxString& entry) const
  {
    VALUE dummy;
    return getEntry(entry, dummy);
  }

  bool getGroup(const wxString& grpName, VALUE& rbGrp) const
  {
    if (NIL_P(m_cfgGroup)) return false;

    VALUE rbGrpName = WXSTR_TO_RSTR(grpName);
    if (rb_hash_includes(m_cfgGroup, rbGrpName))
    {
      VALUE rbVal = rb_hash_aref(m_cfgGroup, rbGrpName);
      if (TYPE(rbVal) == T_HASH)
      {
        rbGrp = rbVal;
        return true;
      }
    }
    return false;
  }

  bool hasGroup(const wxString& grpName) const
  {
    VALUE dummy;
    return getGroup(grpName, dummy);
  }

  void SetRootPath()
  {
    m_strPath.Empty();
    m_cfgGroup = m_cfgHash;
    m_cfgGroupKeys = Qnil;
  }

  // real SetPath() implementation, returns true if path could be set or false
  // if path doesn't exist and createMissingComponents == false
  bool DoSetPath(const wxString& strPath, bool createMissingComponents)
  {
    if ( strPath.empty() )
    {
        SetRootPath();
        return true;
    }

    VALUE rbPath;
    if ( strPath[0] == wxCONFIG_PATH_SEPARATOR )
    {
        // absolute path
        rbPath = WXSTR_TO_RSTR(strPath);
    }
    else
    {
        // relative path, combine with current one
        wxString strFullPath = m_strPath;
        strFullPath << wxCONFIG_PATH_SEPARATOR << strPath;
        rbPath = WXSTR_TO_RSTR(strFullPath);
    }

    // split the path
    VALUE rbSegments = rb_funcall(rbPath, split_ID(), 1, WXSTR_TO_RSTR(cfgSepStr));
    // prune the segments (remove relative elements)
    for (long i=0; i<RARRAY_LEN(rbSegments) ;)
    {
      VALUE rbSeg = rb_ary_entry(rbSegments, i);
      if (RSTR_TO_WXSTR(rbSeg) == "..")
      {
        // remove the 'prev-dir' indicator
        rb_ary_delete_at(rbSegments, i);
        // remove the prev group level (if any)
        if (i>0)
        {
          rb_ary_delete_at(rbSegments, --i);
        }
      }
      else if (RSTR_TO_WXSTR(rbSeg) == ".")
      {
        // remove the 'cur-dir' indicator
        rb_ary_delete_at(rbSegments, i);
      }
      else
      {
        ++i; // next
      }
    }
    // set current group
    VALUE rbCurGrp = m_cfgHash;
    for (VALUE rbSeg=rb_ary_shift(rbSegments); !NIL_P(rbSeg) ;rbSeg=rb_ary_shift(rbSegments))
    {
      VALUE rbEntry = rb_hash_aref(rbCurGrp, rbSeg);
      if (NIL_P(rbEntry) || TYPE(rbEntry) != T_HASH)
      {
        if (!createMissingComponents)
          return false;

        // NOTE: this will overwrite any value entry with the same name as
        //       as the new group
        rbEntry = rb_hash_new();
        rb_hash_aset(rbCurGrp, rbSeg, rbEntry);
      }
      rbCurGrp = rbEntry;
    }

    // set new current group
    m_cfgGroup = rbCurGrp;
    m_cfgGroupKeys = Qnil; // reset
    // set new current path
    m_strPath = RSTR_TO_WXSTR(rbPath);

    return true;
  }


  // member variables
  // ----------------
  VALUE       m_cfgHash;                // Ruby Hash store
  VALUE       m_cfgGroup;               // Ruby Current Group Hash store
  VALUE       m_cfgGroupKeys;           // Ruby Current Group Keys Array
  wxString    m_strPath;                // current path (not '/' terminated)

  wxDECLARE_NO_COPY_CLASS(wxRbHashConfig);
}; // wxRbHashConfig

WxRuby_ID wxRbHashConfig::split_ID("split");
wxString wxRbHashConfig::cfgSepStr(wxCONFIG_PATH_SEPARATOR);
WxRuby_ID wxRbHashConfig::keys_ID("keys");
WxRuby_ID wxRbHashConfig::to_s_ID("to_s");
WxRuby_ID wxRbHashConfig::to_i_ID("to_i");
WxRuby_ID wxRbHashConfig::to_f_ID("to_f");

// Wrap a Ruby hash for input type mapping
WXRUBY_EXPORT wxConfigBase* wxRuby_Ruby2ConfigBase(VALUE rbHash)
{
  return new wxRbHashConfig(rbHash);
}

// Return Ruby hash from wx config (either the wrapped hash or a new converted one)
WXRUBY_EXPORT VALUE wxRuby_ConfigBase2Ruby(wxConfigBase* config)
{
  if (config)
  {
    wxRbHashConfig* hsh_config = dynamic_cast<wxRbHashConfig*> (config);
    if (hsh_config)
    {
      return hsh_config->GetHash();
    }
  }
  return Qnil;
}

#endif
