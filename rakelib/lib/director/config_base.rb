# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class ConfigBase < Director

      def setup
        super
        spec.items.clear
        spec.add_header_code <<~__HEREDOC
          #include "wxruby-Config.h"
          #include <limits>

          static const char * __iv_ConfigBase_sc_config = "@config";

          static WxRuby_ID s_use_hash_config_id("use_hash_config");

          static void 
          _free_config_wx(void* cfg)
          {
            if (cfg)
            {
              wxConfigBase* config = (wxConfigBase*)cfg;
              delete config;
            }
          }

          static VALUE config_base_get(int argc, VALUE *argv, VALUE self)
          {
            bool autoCreate = true;
            if (argc > 0)
            {
              if (argc > 1)
              {
                rb_raise(rb_eArgError, "Expected a single boolean argument");
                return Qnil;
              }
              autoCreate = !(argv[0] == Qfalse || argv[0] == Qnil); // test truthy-ness
            }

            // get global ConfigBase instance from Ruby instance variable of ConfigBase singleton class
            VALUE cConfigBase_Singleton = rb_funcall(g_cConfigBase, rb_intern("singleton_class"), 0, 0);
            VALUE curConfig = rb_iv_get(cConfigBase_Singleton, __iv_ConfigBase_sc_config);

            if (NIL_P(curConfig))
            {
              wxConfigBase* cfg = wxConfigBase::Get(autoCreate);
              if (cfg)
              {
                // wrap the C++ config object
                curConfig = Data_Wrap_Struct(g_cConfigWx, 0, 0, cfg);
                // store global ConfigBase instance as Ruby instance variable of ConfigBase singleton class
                rb_iv_set(cConfigBase_Singleton, __iv_ConfigBase_sc_config, curConfig);
              }
            } 
            return curConfig;
          }

          static VALUE config_base_create(int argc, VALUE *argv, VALUE self)
          {
            bool forced_create = false;
            bool use_hash = false;
            if (argc>0)
            {
              if (argc>2)
              {
                rb_raise(rb_eArgError, "Unexpected number of arguments.");
                return Qnil;
              }
              if (argc>1 && TYPE(argv[1]) != T_HASH)
              {
                rb_raise(rb_eArgError, "Expected kwargs for 2.");
                return Qnil;
              }
              if ((argc==1 && TYPE(argv[0]) != T_HASH) || argc>1)
              {
                VALUE rb_forced_create = argc==1 ? argv[0] : argv[1];
                forced_create = !(rb_forced_create == Qfalse || rb_forced_create == Qnil); // test truthy-ness
              }
              if (TYPE(argv[argc-1]) == T_HASH)
              {
                VALUE rb_hash = argv[argc-1];
                int hsz = RHASH_SIZE(rb_hash);
                if (hsz>1 || (hsz==1 &&!rb_hash_includes(rb_hash, ID2SYM(s_use_hash_config_id()))))
                {
                  rb_raise(rb_eArgError, "Unexpected keyword argument. Only :use_hash_config allowed.");
                  return Qnil;      
                }

                VALUE rb_use_hash  = rb_hash_aref(rb_hash, ID2SYM(s_use_hash_config_id()));
                use_hash = !(rb_use_hash == Qfalse || rb_use_hash == Qnil); // test truthy-ness
              }
            }

            VALUE curConfig = Qnil;

            // get singleton class
            VALUE cConfigBase_Singleton = rb_funcall(g_cConfigBase, rb_intern("singleton_class"), 0, 0);
            
            // Any existing C++ global instance known? (do not auto-create if not)
            wxConfigBase* config = wxConfigBase::Get(false); 
            if (config == nullptr || forced_create)
            {
              if (use_hash)
              {
                // create new Wx::Config instance
                curConfig = rb_class_new_instance(0, 0, g_cConfig);
                // set global wxConfigBase instance to a new Ruby Config wrapper
                wxConfigBase::Set(wxRuby_Ruby2ConfigBase(curConfig));
              }
              else
              {
                if (config) wxConfigBase::Set(nullptr); // reset
                wxConfigBase* new_cfg = wxConfigBase::Create(); // create new C++ instance
                // wrap the C++ config object
                curConfig = Data_Wrap_Struct(g_cConfigWx, 0, 0, new_cfg);
              }
              // store global ConfigBase instance as Ruby instance variable of ConfigBase singleton class
              // (keeps it safe from GC)
              rb_iv_set(cConfigBase_Singleton, __iv_ConfigBase_sc_config, curConfig);
              if (config)
              {
                // clean up; destroy any previous config instance
                delete config;
              } 
            }
            else
            {
              // check if this instance was already wrapped
              curConfig = rb_iv_get(cConfigBase_Singleton, __iv_ConfigBase_sc_config);
              if (NIL_P(curConfig))
              {
                // no global Ruby instance known so can't be wrapped yet (must be C++ instance than) 
                // wrap the C++ config object
                curConfig = Data_Wrap_Struct(g_cConfigWx, 0, 0, config);
                // store global ConfigBase instance as Ruby instance variable of ConfigBase singleton class
                // (keeps it safe from GC)
                rb_iv_set(cConfigBase_Singleton, __iv_ConfigBase_sc_config, curConfig);
              }
            }
            return curConfig;
          }

          static VALUE config_base_set(int argc, VALUE *argv, VALUE self)
          {
            VALUE newCfg = Qnil;
            if (argc>0)
            {
              if (argc > 1)
              {
                rb_raise(rb_eArgError, "Expected a single argument.");
                return Qnil;
              }
              newCfg = argv[0];
              if (!NIL_P(newCfg) && rb_obj_is_kind_of(newCfg, g_cConfig) != Qtrue)
              {
                rb_raise(rb_eArgError, "Expected a Wx::Config instance");
                return Qnil;
              }
            }

            // get existing config (if any) 
            VALUE cConfigBase_Singleton = rb_funcall(g_cConfigBase, rb_intern("singleton_class"), 0, 0);
            VALUE curConfig = rb_iv_get(cConfigBase_Singleton, __iv_ConfigBase_sc_config);
            // set new config instance (could be nil)
            // set global wxConfigBase instance to a (new) Ruby Hash wrapper (or nullptr)
            wxConfigBase::Set(wxRuby_Ruby2ConfigBase(newCfg));
            rb_iv_set(cConfigBase_Singleton, __iv_ConfigBase_sc_config, newCfg);

            // check curConfig type
            if (!NIL_P(curConfig) && rb_obj_is_kind_of(curConfig, g_cConfigWx) != Qtrue)
            {
              // need to make config Ruby owned to it gets proper GC handling
              // and the C++ allocated config instance gets destroyed 
              RDATA(curConfig)->dfree = _free_config_wx;
            }

            return curConfig; // return old config (if any)
          }

          static WxRuby_ID to_f_id("to_f");
          static WxRuby_ID to_i_id("to_i");
          static WxRuby_ID to_s_id("to_s");
          
          #ifdef wxHAS_LONG_LONG_T_DIFFERENT_FROM_LONG
          #define PO_LONG wxLongLong_t
          #define PO_NUM2LONG(n) NUM2LL(n)
          #define PO_LONG2NUM(l) LL2NUM(l)
          #else
          #define PO_LONG long
          #define PO_NUM2LONG(n) NUM2LONG(n)
          #define PO_LONG2NUM(l) LONG2NUM(l)
          #endif

          static VALUE config_wx_read(int argc, VALUE *argv, VALUE self)
          {
            wxConfigBase *cfg;
            Data_Get_Struct(self, wxConfigBase, cfg);

            if (argc < 1 || argc > 1) 
            {
              rb_raise(rb_eArgError, "wrong # of arguments(%d for 1)", argc);
            }
            wxString key = RSTR_TO_WXSTR(argv[0]);
            wxConfigBase::EntryType vtype = cfg->GetEntryType(key);
            switch(vtype)
            {
              case wxConfigBase::Type_Boolean:
              {
                bool v = false;
                if (cfg->Read(key, &v))
                {
                  return v ? Qtrue : Qfalse;
                }
                break;
              }
              case wxConfigBase::Type_Integer:
              {
                PO_LONG v = 0;
                if (cfg->Read(key, &v))
                {
                  return PO_LONG2NUM(v);
                }
                break;
              }
              case wxConfigBase::Type_Float:
              {
                double v = 0.0;
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

          static VALUE config_wx_write(int argc, VALUE *argv, VALUE self)
          {
            wxConfigBase *cfg;
            Data_Get_Struct(self, wxConfigBase, cfg);

            if (argc < 2 || argc > 2) 
            {
              rb_raise(rb_eArgError, "wrong # of arguments(%d for 2)", argc);
            }
            wxString key = RSTR_TO_WXSTR(argv[0]);
            VALUE value = argv[1];
            bool rc = false;
            switch(TYPE(value))
            {
              case T_TRUE:
              case T_FALSE:
              {
                int32_t v = (value == Qtrue ? 1 : 0);
                rc = cfg->Write(key, v);
                break;
              }
        
              case T_FIXNUM:
              {
                PO_LONG v = PO_NUM2LONG(value);
                if (v > std::numeric_limits<int32_t>::max())
                { rc = cfg->Write(key, PO_NUM2LONG(value)); }
                else
                { rc = cfg->Write(key, static_cast<int32_t> (v)); }
                break;
              }

              case T_BIGNUM:
                {
                  VALUE sval = rb_funcall(value, to_s_id(), 0);
                  rc = cfg->Write(key, RSTR_TO_WXSTR(sval));
                }
                break;
        
              case T_FLOAT:
                rc = cfg->Write(key, NUM2DBL(value));
                break;
        
              case T_STRING:
                rc = cfg->Write(key, RSTR_TO_WXSTR(value));
                break;
        
              default:
                if (rb_respond_to(value, to_i_id()))
                {
                  VALUE ival = rb_funcall(value, to_i_id(), 0);
                  rc = cfg->Write(key, PO_NUM2LONG(ival));
                }
                else if (rb_respond_to(value, to_f_id()))
                {
                  VALUE fval = rb_funcall(value, to_f_id(), 0);
                  rc = cfg->Write(key, NUM2DBL(fval));
                }
                else
                {
                  VALUE sval = rb_funcall(value, to_s_id(), 0);
                  rc = cfg->Write(key, RSTR_TO_WXSTR(sval));
                }
                break;
            }
            return rc ? Qtrue : Qfalse;
          }

          static VALUE config_wx_for_path(int argc, VALUE *argv, VALUE self)
          {
            wxConfigBase *cfg;
            Data_Get_Struct(self, wxConfigBase, cfg);

            if (argc < 1 || argc > 1) 
            {
              rb_raise(rb_eArgError, "wrong # of arguments (%d for 1)", argc);
            }
            wxString name = RSTR_TO_WXSTR(argv[0]);
            wxConfigPathChanger path(cfg, name);
            VALUE rc = Qnil;
            if (rb_block_given_p ())
            {
              VALUE key = WXSTR_TO_RSTR(path.Name());
              rc = rb_yield_values(2, self, key);
            }
            return rc;
          }

          static VALUE config_wx_delete(int argc, VALUE *argv, VALUE self)
          {
            wxConfigBase *cfg;
            Data_Get_Struct(self, wxConfigBase, cfg);

            if (argc < 1 || argc > 1) 
            {
              rb_raise(rb_eArgError, "wrong # of arguments (%d for 1)", argc);
            }
            wxString key = RSTR_TO_WXSTR(argv[0]);
            VALUE rc = Qfalse;
            if (cfg->HasGroup(key))
            {
              rc = cfg->DeleteGroup(key) ? Qtrue : Qfalse;
            }
            else if (cfg->HasEntry(key))
            {
              rc = cfg->DeleteEntry(key) ? Qtrue : Qfalse;
            }
            return rc;
          }

          static VALUE config_wx_rename(int argc, VALUE *argv, VALUE self)
          {
            wxConfigBase *cfg;
            Data_Get_Struct(self, wxConfigBase, cfg);

            if (argc < 2 || argc > 2) 
            {
              rb_raise(rb_eArgError, "wrong # of arguments (%d for 2)", argc);
            }
            wxString key = RSTR_TO_WXSTR(argv[0]);
            wxString newKey = RSTR_TO_WXSTR(argv[1]);
            VALUE rc = Qfalse;
            if (cfg->HasGroup(key))
            {
              rc = cfg->RenameGroup(key, newKey) ? Qtrue : Qfalse;
            }
            else
            {
              rc = cfg->RenameEntry(key, newKey) ? Qtrue : Qfalse;
            }
            return rc;
          }

          static VALUE config_wx_each_entry(int argc, VALUE *argv, VALUE self)
          {
            wxConfigBase *cfg;
            Data_Get_Struct(self, wxConfigBase, cfg);

            if (argc < 0 || argc > 0) 
            {
              rb_raise(rb_eArgError, "wrong # of arguments (%d for 0)", argc);
            }
            wxString key;
            long index = 0;
            VALUE rc = Qnil;
            if (rb_block_given_p())
            {
              if (cfg->GetFirstEntry(key, index))
              {
                do {
                  VALUE rb_key = WXSTR_TO_RSTR(key);
                  rc = rb_yield(rb_key);
                } while (cfg->GetNextEntry(key, index));
              }
            }
            return rc;
          }

          static VALUE config_wx_each_group(int argc, VALUE *argv, VALUE self)
          {
            wxConfigBase *cfg;
            Data_Get_Struct(self, wxConfigBase, cfg);

            if (argc < 0 || argc > 0) 
            {
              rb_raise(rb_eArgError, "wrong # of arguments (%d for 0)", argc);
            }
            wxString key;
            long index = 0;
            VALUE rc = Qnil;
            if (rb_block_given_p())
            {
              if (cfg->GetFirstGroup(key, index))
              {
                do {
                  VALUE rb_key = WXSTR_TO_RSTR(key);
                  rc = rb_yield(rb_key);
                } while (cfg->GetNextGroup(key, index));
              }
            }
            return rc;
          }

          static VALUE config_wx_number_of_entries(int argc, VALUE *argv, VALUE self)
          {
            wxConfigBase *cfg;
            Data_Get_Struct(self, wxConfigBase, cfg);

            if (argc < 0 || argc > 2) 
            {
              rb_raise(rb_eArgError, "wrong # of arguments (%d for 1)", argc);
            }
            bool recurse = argc>0 ? (argv[0] != Qfalse && argv[0] != Qnil) : false; 
            size_t n = cfg->GetNumberOfEntries(recurse);
            return LONG2NUM(n);
          }

          static VALUE config_wx_number_of_groups(int argc, VALUE *argv, VALUE self)
          {
            wxConfigBase *cfg;
            Data_Get_Struct(self, wxConfigBase, cfg);

            if (argc < 0 || argc > 2) 
            {
              rb_raise(rb_eArgError, "wrong # of arguments (%d for 1)", argc);
            }
            bool recurse = argc>0 ? (argv[0] != Qfalse && argv[0] != Qnil) : false; 
            size_t n = cfg->GetNumberOfGroups(recurse);
            return LONG2NUM(n);
          }

          static VALUE config_wx_has_entry(int argc, VALUE *argv, VALUE self)
          {
            wxConfigBase *cfg;
            Data_Get_Struct(self, wxConfigBase, cfg);

            if (argc < 1 || argc > 1) 
            {
              rb_raise(rb_eArgError, "wrong # of arguments(%d for 1)", argc);
            }
            wxString path = RSTR_TO_WXSTR(argv[0]);
            return cfg->HasEntry(path) ? Qtrue : Qfalse;
          }

          static VALUE config_wx_has_group(int argc, VALUE *argv, VALUE self)
          {
            wxConfigBase *cfg;
            Data_Get_Struct(self, wxConfigBase, cfg);

            if (argc < 1 || argc > 1) 
            {
              rb_raise(rb_eArgError, "wrong # of arguments (%d for 1)", argc);
            }
            wxString path = RSTR_TO_WXSTR(argv[0]);
            return cfg->HasGroup(path) ? Qtrue : Qfalse;
          }

          static VALUE config_wx_path(int argc, VALUE *argv, VALUE self)
          {
            wxConfigBase *cfg;
            Data_Get_Struct(self, wxConfigBase, cfg);

            if (argc < 0 || argc > 2) 
            {
              rb_raise(rb_eArgError, "wrong # of arguments (%d for 1)", argc);
            }
            return WXSTR_TO_RSTR(cfg->GetPath());
          }

          static VALUE config_wx_clear(int argc, VALUE *argv, VALUE self)
          {
            wxConfigBase *cfg;
            Data_Get_Struct(self, wxConfigBase, cfg);

            if (argc < 0 || argc > 2) 
            {
              rb_raise(rb_eArgError, "wrong # of arguments (%d for 1)", argc);
            }
            return cfg->DeleteAll() ? Qtrue : Qfalse;
          }

          static VALUE config_wx_is_expanding_env_vars(int argc, VALUE *argv, VALUE self)
          {
            wxConfigBase *cfg;
            Data_Get_Struct(self, wxConfigBase, cfg);

            if (argc != 0) 
            {
              rb_raise(rb_eArgError, "No arguments expected");
            }
            return cfg->IsExpandingEnvVars() ? Qtrue : Qfalse;
          }

          static VALUE config_wx_set_expand_env_vars(int argc, VALUE *argv, VALUE self)
          {
            wxConfigBase *cfg;
            Data_Get_Struct(self, wxConfigBase, cfg);

            if (argc < 1 || argc > 1) 
            {
              rb_raise(rb_eArgError, "wrong # of arguments (%d for 1)", argc);
            }
            bool expand = (argv[0] != Qfalse && argv[0] != Qnil);
            cfg->SetExpandEnvVars(expand);
            return Qnil;
          }
          __HEREDOC
        spec.add_wrapper_code <<~__HEREDOC
          SWIGINTERN void 
          _free_config(void* cfg)
          {
            if (cfg)
            {
              wxRbHashConfig* config = (wxRbHashConfig*)cfg;
              config->ResetRubyConfig();
              delete config;
            }
          }

          SWIGINTERN VALUE
          #ifdef HAVE_RB_DEFINE_ALLOC_FUNC
          config_allocate(VALUE self)
          #else
          config_allocate(int argc, VALUE *argv, VALUE self)
          #endif
          {
            VALUE vresult = Data_Wrap_Struct(g_cConfig, 0, _free_config, 0);
          #ifndef HAVE_RB_DEFINE_ALLOC_FUNC
            rb_obj_call_init(vresult, argc, argv);
          #endif
            return vresult;
          }
          __HEREDOC
        spec.add_init_code <<~__HEREDOC
          g_cConfigBase = rb_define_class_under(mWxCore, "ConfigBase", rb_cObject);
          rb_define_module_function(g_cConfigBase, "create", VALUEFUNC(config_base_create), -1);
          rb_define_module_function(g_cConfigBase, "get", VALUEFUNC(config_base_get), -1);
          rb_define_module_function(g_cConfigBase, "set", VALUEFUNC(config_base_set), -1);

          g_cConfigWx = rb_define_class_under(mWxCore, "ConfigWx", g_cConfigBase);
          rb_undef_alloc_func(g_cConfigWx);
          rb_define_protected_method(g_cConfigWx, "read_entry", VALUEFUNC(config_wx_read), -1);
          rb_define_protected_method(g_cConfigWx, "write_entry", VALUEFUNC(config_wx_write), -1);
          rb_define_method(g_cConfigWx, "for_path", VALUEFUNC(config_wx_for_path), -1);
          rb_define_method(g_cConfigWx, "each_entry", VALUEFUNC(config_wx_each_entry), -1);
          rb_define_method(g_cConfigWx, "each_group", VALUEFUNC(config_wx_each_group), -1);
          rb_define_method(g_cConfigWx, "number_of_entries", VALUEFUNC(config_wx_number_of_entries), -1);
          rb_define_method(g_cConfigWx, "number_of_groups", VALUEFUNC(config_wx_number_of_groups), -1);
          rb_define_method(g_cConfigWx, "has_entry?", VALUEFUNC(config_wx_has_entry), -1);
          rb_define_method(g_cConfigWx, "has_group?", VALUEFUNC(config_wx_has_group), -1);
          rb_define_method(g_cConfigWx, "delete", VALUEFUNC(config_wx_delete), -1);
          rb_define_method(g_cConfigWx, "rename", VALUEFUNC(config_wx_rename), -1);
          rb_define_method(g_cConfigWx, "path", VALUEFUNC(config_wx_path), -1);
          rb_define_method(g_cConfigWx, "clear", VALUEFUNC(config_wx_clear), -1);
          rb_define_method(g_cConfigWx, "is_expanding_env_vars", VALUEFUNC(config_wx_is_expanding_env_vars), -1);
          rb_define_alias(g_cConfigWx, "expanding_env_vars?", "is_expanding_env_vars");
          rb_define_method(g_cConfigWx, "set_expand_env_vars", VALUEFUNC(config_wx_set_expand_env_vars), -1);
          rb_define_alias(g_cConfigWx, "expand_env_vars=", "set_expand_env_vars");

          g_cConfig = rb_define_class_under(mWxCore, "Config", g_cConfigBase);
          rb_define_alloc_func(g_cConfig, config_allocate);
          __HEREDOC
      end

    end

  end

end
