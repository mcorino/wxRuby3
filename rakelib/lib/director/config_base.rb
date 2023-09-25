###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class ConfigBase < Director

      def setup
        super
        spec.items.clear
        spec.add_header_code <<~__HEREDOC
          #include "wxruby-Config.h"

          static const char * __iv_ConfigBase_sc_config = "@config";

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
              autoCreate = !(argv[0] == Qfalse || argv[0] == Qnil);
            }

            VALUE cConfigBase_Singleton = rb_funcall(g_cConfigBase, rb_intern("singleton_class"), 0, 0);
            VALUE curConfig = rb_iv_get(cConfigBase_Singleton, __iv_ConfigBase_sc_config);
            // create new config instance if none exists and autoCreate is true
            if (NIL_P(curConfig) && autoCreate)
            {
              // create new ConfigBase instance
              curConfig = rb_class_new_instance(0, 0, g_cConfigBase);
              // set global wxConfigBase instance to a new Ruby Hash wrapper
              wxConfigBase::Set(wxRuby_Ruby2ConfigBase(curConfig));
              // store global ConfigBase instance as Ruby instance variable of ConfigBase singleton class
              // (keeps it safe from GC)
              VALUE cConfigBase_Singleton = rb_funcall(g_cConfigBase, rb_intern("singleton_class"), 0, 0);
              rb_iv_set(cConfigBase_Singleton, __iv_ConfigBase_sc_config, curConfig);
            }
            return curConfig;
          }

          static VALUE config_base_create(int argc, VALUE *argv, VALUE self)
          {
            if (argc>0)
            {
              rb_raise(rb_eArgError, "No arguments allowed.");
              return Qnil;
            }
            return config_base_get(0, 0, self);
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
              if (!NIL_P(newCfg) && rb_obj_is_kind_of(newCfg, g_cConfigBase) != Qtrue)
              {
                rb_raise(rb_eArgError, "Expected a Wx::ConfigBase instance");
                return Qnil;
              }
            }

            // get existing config (if any) 
            VALUE cConfigBase_Singleton = rb_funcall(g_cConfigBase, rb_intern("singleton_class"), 0, 0);
            VALUE curConfig = rb_iv_get(cConfigBase_Singleton, __iv_ConfigBase_sc_config);
            // set new config instance (could be nil)
            if (!NIL_P(newCfg))
            {
              // set global wxConfigBase instance to a (new) Ruby Hash wrapper
              wxConfigBase::Set(wxRuby_Ruby2ConfigBase(newCfg));
            }
            rb_iv_set(cConfigBase_Singleton, __iv_ConfigBase_sc_config, newCfg);

            return curConfig; // return old config (if any)
          }

          __HEREDOC
        spec.add_init_code <<~__HEREDOC
          g_cConfigBase = rb_define_class_under(mWxCore, "ConfigBase", rb_cObject);
          rb_define_module_function(g_cConfigBase, "create", VALUEFUNC(config_base_create), -1);
          rb_define_module_function(g_cConfigBase, "get", VALUEFUNC(config_base_get), -1);
          rb_define_module_function(g_cConfigBase, "set", VALUEFUNC(config_base_set), -1);
          __HEREDOC
      end

    end

  end

end
