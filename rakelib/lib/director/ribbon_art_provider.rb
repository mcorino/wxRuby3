# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class RibbonArtProvider < Director

      def setup
        spec.items << 'wxRibbonPageTabInfo' << 'wxRibbonMSWArtProvider' << 'wxRibbonAUIArtProvider'
        super
        spec.gc_as_object 'wxRibbonArtProvider'
        spec.make_abstract 'wxRibbonArtProvider'
        spec.gc_as_untracked 'wxRibbonPageTabInfo'
        spec.suppress_warning(473,
                              'wxRibbonArtProvider::Clone',
                              'wxRibbonMSWArtProvider::Clone',
                              'wxRibbonAUIArtProvider::Clone')
        # argout type mappings
        spec.map_apply 'int *OUTPUT' => ['int *ideal', 'int *small_begin_need_separator',
                                         'int *small_must_have_separator', 'int *minimum']
        # wxDirection argout type mapping
        spec.map 'wxDirection *' => 'Wx::Direction' do
          map_in ignore: true, temp: 'wxDirection tmp', code: '$1 = &tmp;'
          map_argout code: <<~__CODE
            $result = SWIG_Ruby_AppendOutput($result, wxRuby_GetEnumValueObject("wxDirection", static_cast<int>(tmp$argnum)));
            __CODE

          map_directorargout code: <<~__CODE
            if ($1 && !NIL_P($result)) 
            {
              int eval;
              wxRuby_GetEnumValue("wxDirection", $result, eval);
              (*$1) = static_cast<wxDirection> (eval);
            }
            __CODE
        end
        spec.map 'wxRibbonGalleryItem*' => 'Integer' do
          map_in code: '$1 = reinterpret_cast<wxRibbonGalleryItem*> ((uintptr_t)NUM2ULL($input));'
          map_directorin code: '$input = ULL2NUM(reinterpret_cast<uintptr_t> ($1));'
          map_typecheck precedence: 'INTEGER', code: '$1 = (TYPE($input) == T_FIXNUM);'
        end
        # add method for correctly wrapping RibbonArtProvider references
        spec.add_header_code <<~__CODE
            extern VALUE mWxRBN; // declare external module reference
            extern VALUE wxRuby_WrapWxRibbonArtProviderInRuby(const wxRibbonArtProvider *wx_rap, int own)
            {
              // If no object was passed to be wrapped.
              if ( ! wx_rap )
                return Qnil;

              // check for registered instance
              VALUE rb_rap = wxRuby_FindTracking(const_cast<wxRibbonArtProvider*> (wx_rap));
              if (rb_rap && !NIL_P(rb_rap))
              {
                return rb_rap;
              }

              const void *ptr = 0;
              wxString class_name;
              if ((ptr = dynamic_cast<const wxRibbonAUIArtProvider*> (wx_rap)))
              {
                class_name = "RibbonAUIArtProvider";
              }
              else if ((ptr = dynamic_cast<const wxRibbonMSWArtProvider*> (wx_rap)))
              {
                class_name = "RibbonMSWArtProvider";
              }
              else
              {
                class_name = "RibbonArtProvider";
              }
              VALUE r_class = Qnil;
              if ( ptr && class_name.Len() > 0 )
              {
                wxCharBuffer wx_classname = class_name.mb_str();
                VALUE r_class_name = rb_intern(wx_classname.data ()); // wxRuby class name
                if (rb_const_defined(mWxRBN, r_class_name))
                  r_class = rb_const_get(mWxRBN, r_class_name);
              }

              // If we cannot find the class output a warning and return nil
              if ( r_class == Qnil )
              {
                rb_warn("Error wrapping object; class `%s' is not (yet) supported in wxRuby",
                        (const char *)class_name.mb_str() );
                return Qnil;
              }

              // Otherwise, retrieve the swig type info for this class and wrap it
              // in Ruby. 
              swig_type_info* swig_type = wxRuby_GetSwigTypeForClass(r_class);
              rb_rap = SWIG_NewPointerObj(const_cast<void*> (ptr), swig_type, own);
              return rb_rap;
            }
        __CODE
        # type mapping for Clone return ref
        spec.map 'wxRibbonArtProvider*' => 'Wx::RBN::RibbonArtProvider' do
          # add_header_code 'extern VALUE wxRuby_WrapWxRibbonArtProviderInRuby(const wxRibbonArtProvider *wx_rap, int own);'
          # wrap AND own in this case
          map_out code: '$result = wxRuby_WrapWxRibbonArtProviderInRuby($1, 1);'
        end
        # type mapping for wxRibbonPageTabInfoArray; no need to expose it to Ruby
        spec.map 'const wxRibbonPageTabInfoArray &' => 'Array<Wx::RBN::RibbonPageTabInfo>' do
          map_in temp: 'wxRibbonPageTabInfoArray tmp', code: <<~__CODE
            if (!NIL_P($input))
            {
              if (TYPE($input) == T_ARRAY)
              {
                for (int i=0; i<RARRAY_LEN($input) ;++i)
                {
                  VALUE rb_el = rb_ary_entry($input, i);
                  void* ptr = 0;
                  int res = SWIG_ConvertPtr(rb_el, &ptr, SWIGTYPE_p_wxRibbonPageTabInfo,  0);
                  if (!SWIG_IsOK(res) || ptr == 0) 
                  {
                    const char* msg;
                    VALUE rb_msg;
                    if (ptr)
                    {
                      rb_msg = rb_inspect(rb_el);
                      msg = StringValuePtr(rb_msg);
                    }
                    else
                    {
                      msg = "null reference";
                    }
                    rb_raise(rb_eTypeError, "$symname : expected Wx::RBN::RibbonPageTabInfo for array element for 3 but got %s",
                             msg);
                  }
                  tmp.Add(*reinterpret_cast< wxRibbonPageTabInfo * >(ptr));
                }
              }
              else
              {
                VALUE msg = rb_inspect($input);
                rb_raise(rb_eArgError, "$symname : expected array for 3 but got %s",
                         StringValuePtr(msg));
              }
            }
            $1 = &tmp;
            __CODE
          map_directorin code: <<~__CODE
            $input = rb_ary_new();
            for (size_t i = 0; i < $1.GetCount(); i++)
            {
              wxRibbonPageTabInfo* wx_rbti = &$1.Item(i);
              rb_ary_push($input, SWIG_NewPointerObj(SWIG_as_voidptr(wx_rbti), SWIGTYPE_p_wxRibbonPageTabInfo, 0));
            }
            __CODE
        end
      end
    end # class RibbonArtProvider

  end # class Director

end # module WXRuby3
