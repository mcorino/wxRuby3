###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class PropertyGridInterface < Director

      include Typemap::DateTime

      def setup
        super
        spec.items << 'wxPGPropArgCls'
        spec.gc_as_temporary 'wxPGPropArgCls'
        spec.gc_as_temporary 'wxPropertyGridInterface' # actually no GC control necessary as this is a mixin only
        spec.add_swig_code 'typedef const wxPGPropArgCls& wxPGPropArg;'
        # ignore unuseful shadowing overloads
        spec.ignore 'wxPropertyGridInterface::SetPropertyValue(wxPGPropArg, wxObject &)',
                    'wxPropertyGridInterface::SetPropertyValue(wxPGPropArg, const wchar_t *)',
                    'wxPropertyGridInterface::SetPropertyValue(wxPGPropArg, const char *)',
                    'wxPGPropArgCls::wxPGPropArgCls(const char *)',
                    'wxPGPropArgCls::wxPGPropArgCls(const wchar_t *)'
        # SWIG chokes on the specified 'defaultCategory' default arg
        spec.ignore 'wxPropertyGridInterface::SetPropertyValues', ignore_doc: false
        # so redeclare in way SWIG can process
        spec.add_header_code '#define WXRB_NULL_PROP_ARG wxPGPropArgCls((wxPGProperty*)0)'
        spec.extend_interface 'wxPropertyGridInterface',
                              'void SetPropertyValues(const wxVariantList &list, const wxPGPropArgCls& defaultCategory=WXRB_NULL_PROP_ARG)',
                              'void SetPropertyValues(const wxVariant &list, const wxPGPropArgCls& defaultCategory=WXRB_NULL_PROP_ARG)'
        # don't expose wxPGAttributeStorage; add a more Ruby-like extension
        spec.ignore 'wxPropertyGridInterface::GetPropertyAttributes'
        spec.add_extend_code 'wxPropertyGridInterface', <<~__HEREDOC
          VALUE each_property_attribute(const wxPGPropArgCls& proparg)
          {
            const wxPGAttributeStorage& att_store = self->GetPropertyAttributes(proparg);
            wxPGAttributeStorage::const_iterator it = att_store.StartIteration();
            wxVariant att_var;
            VALUE rc = Qnil;
            while (att_store.GetNext(it, att_var))
            {
              VALUE rb_att_var = SWIG_NewPointerObj(new wxVariant(att_var), SWIGTYPE_p_wxVariant, SWIG_POINTER_OWN);
              rc = rb_yield(rb_att_var);
            }
            return rc;
          }
        __HEREDOC
        # not useful in wxRuby
        spec.ignore 'wxPGPropArgCls::GetPtr(wxPropertyGridInterface *) const',
                    'wxPGPropArgCls::GetPtr(const wxPropertyGridInterface *) const',
                    'wxPGPropArgCls::GetPtr0() const',
                    'wxPGPropArgCls::wxPGPropArgCls(wxString *, bool)'

        spec.make_abstract 'wxPropertyGridInterface'
        spec.no_proxy 'wxPropertyGridInterface'
        spec.post_processors << :make_property_grid_interface_mixin
        spec.add_header_code <<~__HEREDOC
          typedef wxPropertyGridInterface* (*wx_convert_fn)(void*);
          // Mapping of swig_class* to wx_convert_fn
          WX_DECLARE_VOIDPTR_HASH_MAP(wx_convert_fn,
                                      WXRBMixinCasterHash);
          static WXRBMixinCasterHash Mixin_Include_Cast_Map;

          WXRB_EXPORT_FLAG void wxRuby_Register_PropertyGridInterface_Include(swig_class* cls_info, wx_convert_fn converter)
          {
            Mixin_Include_Cast_Map[cls_info] = converter;
          }
          
          static wxPropertyGridInterface* wxRuby_ConvertToPropertyGridInterface(VALUE obj)
          {
            if (NIL_P(obj)) return 0;
            
            if (TYPE(obj) != T_DATA)
            {
              VALUE msg = rb_inspect(obj);
              rb_raise(rb_eArgError, 
                       "Expected a PropertyGridInterface but got %s", 
                       StringValuePtr(msg));
            }

            WXRBMixinCasterHash::iterator it;
            for( it = Mixin_Include_Cast_Map.begin(); it != Mixin_Include_Cast_Map.end(); ++it )
            {
              swig_class* cls_info = static_cast<swig_class*> (it->first);
              if (rb_obj_is_kind_of(obj, cls_info->klass))
              {
                void *ptr = 0;
                /* Grab the pointer */
                Data_Get_Struct(obj, void, ptr);
                wx_convert_fn fn_cvt = it->second;
                return (*fn_cvt)(ptr);
              }
            }
            
            VALUE msg = rb_inspect(obj);
            rb_raise(rb_eTypeError, 
                     "Unable to convert %s to PropertyGridInterface", 
                     StringValuePtr(msg));
          }
          __HEREDOC
        spec.do_not_generate :variables, :defines, :enums, :functions # with pgproperty
      end
    end # class PropertyGridInterface

  end # class Director

  module SwigRunner
    # need to transform the SWIG generated class wrapper into a mixin module wrapper
    class Processor
      class MakePropertyGridInterfaceMixin < Processor
        def run
          skip_method = false
          skip_conversion = false
          update_source do |line|
            if skip_method
              skip_method = false if /\A}\s*\Z/ =~ line # end of function?
              line = nil # remove line in output
            elsif skip_conversion
              if /\A(\s*arg1\s*=\s*)reinterpret_cast<\s*wxPropertyGridInterface/ =~ line
                skip_conversion = false
                line = "#{$1}wxRuby_ConvertToPropertyGridInterface(self);"
              else
                line = nil
              end
            else
              # transform conversion of 'self' in wrapper functions
              if /\A(\s*)res1\s*=\s*SWIG_ConvertPtr\(self,\s*&argp1,SWIGTYPE_p_wxPropertyGridInterface/ =~ line
                skip_conversion = true
                line = "#{$1}wxUnusedVar(res1); wxUnusedVar(argp1);"
              # remove unwanted function definitions
              elsif /\Afree_wxPropertyGridInterface/ =~ line
                line = "free_wxPropertyGridInterface() {}"
                skip_method = true
              # replace the class creation by a module creation
              elsif /\A(\s*SwigClassWxPropertyGridInterface.klass\s*=\s*)rb_define_class_under\(\s*(\w+)\s*,\s*\"(\w+)\"/ =~ line
                line = %Q{#{$1}rb_define_module_under(#{$2}, "#{$3}");}
              # remove the alloc undef line
              elsif /\A\s*rb_undef_alloc_func\s*\(SwigClassWxPropertyGridInterface.klass/ =~ line
                line = nil
              # as well as the lifecycle method setups
              elsif /\A\s*SwigClassWxPropertyGridInterface\.(mark|destroy|trackObjects)\s*=/ =~ line
                line = nil
              end
            end
            line
          end
        end
      end
    end
  end

end # module WXRuby3
