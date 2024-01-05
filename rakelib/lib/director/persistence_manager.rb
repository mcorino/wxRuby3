# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class PersistenceManager < Director

      include Typemap::ConfigBase

      def setup
        super
        spec.gc_as_marked
        spec.use_class_implementation 'wxPersistenceManager', 'WxRubyPersistenceManager'
        spec.ignore 'wxPersistenceManager::Register',
                    'wxPersistenceManager::Find',
                    'wxPersistenceManager::Unregister',
                    'wxPersistenceManager::Save',
                    'wxPersistenceManager::Restore',
                    'wxPersistenceManager::SaveAndUnregister',
                    'wxPersistenceManager::RegisterAndRestore',
                    ignore_doc: false
        # doc gen only
        spec.map 'void *obj' => 'Object', swig: false do
          map_in code: ''
        end
        spec.map 'T *obj' => 'Object', swig: false do
          map_in code: ''
        end
        spec.regard 'wxPersistenceManager::wxPersistenceManager',
                    'wxPersistenceManager::GetConfig',
                    'wxPersistenceManager::GetKey'
        spec.suppress_warning 473, 'wxPersistenceManager::GetConfig'
        spec.ignore %w[wxCreatePersistentObject wxPersistentRegisterAndRestore]
        spec.add_header_code <<~__HEREDOC
          #include "wxruby-Persistence.h"

          // default global wxRuby persistence manager
          static WxRubyPersistenceManager s_wxruby_persistence_manager {};

          static WxRuby_ID to_f_id("to_f");
          static WxRuby_ID to_i_id("to_i");
          static WxRuby_ID to_s_id("to_s");
          static WxRuby_ID save_value_id("save_value");
          static WxRuby_ID restore_value_id("save_value");
          static WxRuby_ID create_po_id("create_persistent_object");
          
          #ifdef wxHAS_LONG_LONG_T_DIFFERENT_FROM_LONG
          #define PO_LONG wxLongLong_t
          #define PO_NUM2LONG(n) NUM2LL(n)
          #define PO_LONG2NUM(l) LL2NUM(l)
          #else
          #define PO_LONG long
          #define PO_NUM2LONG(n) NUM2LONG(n)
          #define PO_LONG2NUM(l) LONG2NUM(l)
          #endif

          bool WxRubyPersistenceManager::SaveRubyValue(const wxPersistentObject& who, const wxString& name, VALUE value)
          {
            Swig::Director* dir = dynamic_cast<Swig::Director*> (this);
            // is this a user defined Ruby persistence manager with overridden #save_value?
            if (dir && !wxRuby_IsNativeMethod(dir->swig_get_self(), save_value_id())) 
            {
              VALUE rb_who = SWIG_NewPointerObj(SWIG_as_voidptr(&who), SWIGTYPE_p_wxPersistentObject,  0 );
              return wxRuby_Funcall(dir->swig_get_self(), save_value_id(), 3, rb_who, WXSTR_TO_RSTR(name), value);
            }
            else
            {
              // just call C++ base implementation
              return DoSaveRubyValue(who, name, value);
            }
          }

          VALUE WxRubyPersistenceManager::RestoreRubyValue(const wxPersistentObject& who, const wxString& name)
          {
            Swig::Director* dir = dynamic_cast<Swig::Director*> (this);
            // is this a user defined Ruby persistence manager with overridden #restore_value?
            if (dir && !wxRuby_IsNativeMethod(dir->swig_get_self(), restore_value_id())) 
            {
              VALUE rb_who = SWIG_NewPointerObj(SWIG_as_voidptr(&who), SWIGTYPE_p_wxPersistentObject,  0 );
              return wxRuby_Funcall(dir->swig_get_self(), restore_value_id(), 3, rb_who, WXSTR_TO_RSTR(name));
            }
            else
            {
              // just call C++ base implementation
              return DoRestoreRubyValue(who, name);
            }
          }

          bool WxRubyPersistenceManager::DoSaveRubyValue(const wxPersistentObject& who, const wxString& name, VALUE value)
          {
            wxConfigBase* cfg = this->GetConfig();
            if (!cfg)
              return false;
            wxString key = this->GetKey(who, name);
            switch(TYPE(value))
            {
              case T_TRUE:
              case T_FALSE:
                return cfg->Write(key, value == Qtrue);
        
              case T_FIXNUM:
              case T_BIGNUM:
                return cfg->Write(key, PO_NUM2LONG(value));
        
              case T_FLOAT:
                return cfg->Write(key, NUM2DBL(value));
        
              case T_STRING:
                return cfg->Write(key, RSTR_TO_WXSTR(value));
        
              default:
                if (rb_respond_to(value, to_i_id()))
                {
                  VALUE ival = rb_funcall(value, to_i_id(), 0);
                  return cfg->Write(key, PO_NUM2LONG(ival));
                }
                else if (rb_respond_to(value, to_f_id()))
                {
                  VALUE fval = rb_funcall(value, to_f_id(), 0);
                  return cfg->Write(key, NUM2DBL(fval));
                }
                break;
            }
            VALUE sval = rb_funcall(value, to_s_id(), 0);
            return cfg->Write(key, RSTR_TO_WXSTR(sval));
          }

          VALUE WxRubyPersistenceManager::DoRestoreRubyValue(const wxPersistentObject& who, const wxString& name)
          {
            wxConfigBase* cfg = this->GetConfig();
            if (!cfg)
              return Qnil;
            wxString key = this->GetKey(who, name);
            wxConfigBase::EntryType vtype = cfg->GetEntryType(key);
            switch(vtype)
            {
              case wxConfigBase::Type_Boolean:
              {
                bool v;
                if (cfg->Read(key, &v))
                {
                  return v ? Qtrue : Qfalse;
                }
                break;
              }
              case wxConfigBase::Type_Integer:
              {
                PO_LONG v;
                if (cfg->Read(key, &v))
                {
                  return PO_LONG2NUM(v);
                }
                break;
              }
              case wxConfigBase::Type_Float:
              {
                double v;
                if (cfg->Read(key, &v))
                {
                  return DBL2NUM(v);
                }
                break;
              }
              case wxConfigBase::Type_String:
              {
                wxString v;
                if (cfg->Read(key, &v))
                {
                  return WXSTR_TO_RSTR(v);
                }
                break;
              }
              default:
                break;
            }
            return Qnil;
          }

          void WxRubyPersistenceManager::UnregisterPersistentObject(VALUE rb_obj)
          {
            WxRubyPersistenceManager* wxrb_pm = 
              dynamic_cast<WxRubyPersistenceManager*> (&wxPersistenceManager::Get());
            if (wxrb_pm) wxrb_pm->UnregisterRbPO(rb_obj);
          } 

          void WxRubyPersistenceManager::GC_markPO()
          {
            rb_object_to_rb_po_map_t::iterator it;
            for( it = rb_object_po_map_.begin(); it != rb_object_po_map_.end(); ++it )
            {
              rb_gc_mark(it->first);
              rb_gc_mark(it->second);
            }
          }

          static void wxRuby_markPersistentObjects()
          {
            WxRubyPersistenceManager* wxrb_pm = 
              dynamic_cast<WxRubyPersistenceManager*> (&wxPersistenceManager::Get());
            if (wxrb_pm) wxrb_pm->GC_markPO();
          }
          __HEREDOC
        spec.add_extend_code 'wxPersistenceManager', <<~__HEREDOC
          VALUE Register(VALUE obj)
          {
            WxRubyPersistenceManager* wxrb_pm = dynamic_cast<WxRubyPersistenceManager*> ($self);
            VALUE rb_po = rb_funcall(obj, create_po_id(), 0);
            if (!NIL_P(rb_po) && wxrb_pm)
            {
              void* ptr;
              int res = SWIG_ConvertPtr(rb_po, &ptr, SWIGTYPE_p_wxPersistentObject, SWIG_POINTER_DISOWN);
              if (!SWIG_IsOK(res)) 
              {
                rb_raise(rb_eRuntimeError, "Unable to create Wx::PersistentObject for object"); 
              }
              wxPersistentObject* po = reinterpret_cast< wxPersistentObject * >(ptr);
              if ($self->Register(po->GetObject(), po))
              {
                wxrb_pm->RegisterRbPO(obj, rb_po);
                return rb_po;
              }
            }
            return Qnil;
          }

          VALUE Register(VALUE obj, VALUE rb_po)
          {
            WxRubyPersistenceManager* wxrb_pm = dynamic_cast<WxRubyPersistenceManager*> ($self);
            if (!NIL_P(rb_po) && wxrb_pm)
            {
              void* ptr;
              int res = SWIG_ConvertPtr(rb_po, &ptr, SWIGTYPE_p_wxPersistentObject, SWIG_POINTER_DISOWN);
              if (!SWIG_IsOK(res)) 
              {
                rb_raise(rb_eRuntimeError, "Unable to create Wx::PersistentObject for object"); 
              }
              wxPersistentObject* po = reinterpret_cast< wxPersistentObject * >(ptr);
              if ($self->Register(po->GetObject(), po))
              {
                wxrb_pm->RegisterRbPO(obj, rb_po);
                return rb_po;
              }
            }
            return Qnil;
          }

          VALUE Find(VALUE obj)
          {
            WxRubyPersistenceManager* wxrb_pm = dynamic_cast<WxRubyPersistenceManager*> ($self);
            VALUE rb_po = wxrb_pm ? wxrb_pm->FindRbPO(obj) : Qnil;
            if (!NIL_P(rb_po) && wxrb_pm)
            { 
              void* ptr;
              int res = SWIG_ConvertPtr(rb_po, &ptr, SWIGTYPE_p_wxPersistentObject, 0);
              if (!SWIG_IsOK(res)) 
              {
                rb_raise(rb_eRuntimeError, "Invalid Wx::PersistentObject for object"); 
              }
              wxPersistentObject* po = reinterpret_cast< wxPersistentObject * >(ptr);
              if ($self->Find(po->GetObject()))
                return rb_po;
            }
            return Qnil;
          }

          void Unregister(VALUE obj)
          {
            WxRubyPersistenceManager* wxrb_pm = dynamic_cast<WxRubyPersistenceManager*> ($self);
            VALUE rb_po = wxrb_pm ? wxrb_pm->FindRbPO(obj) : Qnil;
            if (!NIL_P(rb_po) && wxrb_pm)
            { 
              void* ptr;
              int res = SWIG_ConvertPtr(rb_po, &ptr, SWIGTYPE_p_wxPersistentObject, 0);
              if (!SWIG_IsOK(res)) 
              {
                rb_raise(rb_eRuntimeError, "Invalid Wx::PersistentObject for object"); 
              }
              wxPersistentObject* po = reinterpret_cast< wxPersistentObject * >(ptr);
              $self->Unregister(po->GetObject());
            }
          }

          void Save(VALUE obj)
          {
            WxRubyPersistenceManager* wxrb_pm = dynamic_cast<WxRubyPersistenceManager*> ($self);
            VALUE rb_po = wxrb_pm ? wxrb_pm->FindRbPO(obj) : Qnil;
            if (!NIL_P(rb_po) && wxrb_pm)
            { 
              void* ptr;
              int res = SWIG_ConvertPtr(rb_po, &ptr, SWIGTYPE_p_wxPersistentObject, 0);
              if (!SWIG_IsOK(res)) 
              {
                rb_raise(rb_eRuntimeError, "Invalid Wx::PersistentObject for object"); 
              }
              wxPersistentObject* po = reinterpret_cast< wxPersistentObject * >(ptr);
              $self->Save(po->GetObject());
            }
          }

          bool Restore(VALUE obj)
          {
            WxRubyPersistenceManager* wxrb_pm = dynamic_cast<WxRubyPersistenceManager*> ($self);
            VALUE rb_po = wxrb_pm ? wxrb_pm->FindRbPO(obj) : Qnil;
            if (!NIL_P(rb_po) && wxrb_pm)
            { 
              void* ptr;
              int res = SWIG_ConvertPtr(rb_po, &ptr, SWIGTYPE_p_wxPersistentObject, 0);
              if (!SWIG_IsOK(res)) 
              {
                rb_raise(rb_eRuntimeError, "Invalid Wx::PersistentObject for object"); 
              }
              wxPersistentObject* po = reinterpret_cast< wxPersistentObject * >(ptr);
              return $self->Restore(po->GetObject());
            }
            return false;
          }

          void SaveAndUnregister(VALUE obj)
          {
            WxRubyPersistenceManager* wxrb_pm = dynamic_cast<WxRubyPersistenceManager*> ($self);
            VALUE rb_po = wxrb_pm ? wxrb_pm->FindRbPO(obj) : Qnil;
            if (!NIL_P(rb_po) && wxrb_pm)
            { 
              void* ptr;
              int res = SWIG_ConvertPtr(rb_po, &ptr, SWIGTYPE_p_wxPersistentObject, 0);
              if (!SWIG_IsOK(res)) 
              {
                rb_raise(rb_eRuntimeError, "Invalid Wx::PersistentObject for object"); 
              }
              wxPersistentObject* po = reinterpret_cast< wxPersistentObject * >(ptr);
              $self->Save(po->GetObject());
              $self->Unregister(po->GetObject());
            }
          }

          bool RegisterAndRestore(VALUE obj)
          {
            WxRubyPersistenceManager* wxrb_pm = dynamic_cast<WxRubyPersistenceManager*> ($self);
            VALUE rb_po = rb_funcall(obj, create_po_id(), 0);
            if (!NIL_P(rb_po) && wxrb_pm)
            {
              void* ptr;
              int res = SWIG_ConvertPtr(rb_po, &ptr, SWIGTYPE_p_wxPersistentObject, SWIG_POINTER_DISOWN);
              if (!SWIG_IsOK(res)) 
              {
                rb_raise(rb_eRuntimeError, "Unable to create Wx::PersistentObject for object"); 
              }
              wxPersistentObject* po = reinterpret_cast< wxPersistentObject * >(ptr);
              if ($self->Register(po->GetObject(), po))
              {
                wxrb_pm->RegisterRbPO(obj, rb_po);
                return $self->Restore(po->GetObject());
              }
            }
            return false;
          }

          bool RegisterAndRestore(VALUE obj, VALUE rb_po)
          {
            WxRubyPersistenceManager* wxrb_pm = dynamic_cast<WxRubyPersistenceManager*> ($self);
            if (!NIL_P(rb_po) && wxrb_pm)
            {
              void* ptr;
              int res = SWIG_ConvertPtr(rb_po, &ptr, SWIGTYPE_p_wxPersistentObject, SWIG_POINTER_DISOWN);
              if (!SWIG_IsOK(res)) 
              {
                rb_raise(rb_eRuntimeError, "Unable to create Wx::PersistentObject for object"); 
              }
              wxPersistentObject* po = reinterpret_cast< wxPersistentObject * >(ptr);
              if ($self->Register(po->GetObject(), po))
              {
                wxrb_pm->RegisterRbPO(obj, rb_po);
                return $self->Restore(po->GetObject());
              }
            }
            return false;
          }
          
          bool SaveValue(const wxPersistentObject& who, const wxString& name, VALUE value)
          {
            WxRubyPersistenceManager* wxrb_pm = dynamic_cast<WxRubyPersistenceManager*> ($self);
            return wxrb_pm ? wxrb_pm->DoSaveRubyValue(who, name, value) : false;
          } 

          VALUE RestoreValue(const wxPersistentObject& who, const wxString& name)
          {
            WxRubyPersistenceManager* wxrb_pm = dynamic_cast<WxRubyPersistenceManager*> ($self);
            return wxrb_pm ? wxrb_pm->DoRestoreRubyValue(who, name) : Qnil;
          }
          __HEREDOC
        spec.add_init_code <<~__HEREDOC
          // install the default global wxRuby persistence manager
          wxPersistenceManager::Set(s_wxruby_persistence_manager);
          // and the persistent object marker
          wxRuby_AppendMarker(wxRuby_markPersistentObjects);
          __HEREDOC
      end

    end # class PersistenceManager

  end # class Director

end # module WXRuby3
