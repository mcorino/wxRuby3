# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './richtext_object'

module WXRuby3

  class Director

    class RichTextCompositeObject < RichTextObject

      include Typemap::RichText

      def setup
        super
        if spec.module_name == 'wxRichTextCompositeObject'
          spec.items << 'wxRichTextParagraph' << 'wxRichTextLine'
          spec.gc_as_untracked 'wxRichTextLine'
          spec.no_proxy 'wxRichTextLine'
          spec.make_abstract 'wxRichTextCompositeObject'
          # for AppendChild, InsertChild
          spec.disown 'wxRichTextObject *child'
          # RemoveChild needs custom wrapper as we need to re-own any child that
          # is removed but NOT deleted
          spec.ignore 'wxRichTextCompositeObject::RemoveChild', ignore_doc: false
          spec.add_extend_code 'wxRichTextCompositeObject', <<~__HEREDOC
            bool RemoveChild(VALUE rb_child, bool deleteChild=false)
            {
              void *ptr;
              int res = SWIG_ConvertPtr(rb_child, &ptr,SWIGTYPE_p_wxRichTextObject, 0);
              if (!SWIG_IsOK(res)) 
              {
                rb_raise(rb_eArgError, "Expected Array of Wx::RTC::RichTextObject for child"); 
              }
              wxRichTextObject* wx_child = reinterpret_cast< wxRichTextObject * >(ptr);
              bool rc = $self->RemoveChild(wx_child, deleteChild);
              if (rc && !deleteChild)
              {
                RDATA(rb_child)->dfree = GC_RichTextObjectFreeFunc; // make sure Ruby owns
              }
              return rc;
            }
            __HEREDOC

          spec.new_object 'wxRichTextLine::Clone'

          spec.map 'const wxRichTextLineVector&' => 'Array<Wx::RTC::RichTextLine' do

            map_out code: <<~__CODE
              $result = rb_ary_new();
              for (const wxRichTextLine *wx_rtl : *$1)
              {
                rb_ary_push($result, SWIG_NewPointerObj(SWIG_as_voidptr(const_cast<wxRichTextLine*> (wx_rtl)), SWIGTYPE_p_wxRichTextLine, 0));
              }
              __CODE

          end

          # create a lightweight, but typesafe, wrapper for wxRichTextFloatCollector
          spec.add_init_code <<~__HEREDOC
            // define wxRichTextFloatCollector wrapper class
            mWxRichTextFloatCollector = rb_define_class_under(mWxRTC, "RichTextFloatCollector", rb_cObject);
            rb_undef_alloc_func(mWxRichTextFloatCollector);
            __HEREDOC

          spec.add_header_code <<~__HEREDOC
            VALUE mWxRichTextFloatCollector;
  
            // wxRichTextFloatCollector wrapper class definition and helper functions
            static size_t __wxRichTextFloatCollector_size(const void* data)
            {
              return 0;
            }
  
            #include <ruby/version.h> 
  
            static const rb_data_type_t __wxRichTextFloatCollector_type = {
              "RichTextFloatCollector",
            #if RUBY_API_VERSION_MAJOR >= 3
              { NULL, NULL, __wxRichTextFloatCollector_size, 0, 0},
            #else
              { NULL, NULL, __wxRichTextFloatCollector_size, 0},
            #endif 
              NULL, NULL, RUBY_TYPED_FREE_IMMEDIATELY
            };
  
            extern VALUE _wxRuby_Wrap_wxRichTextFloatCollector(wxRichTextFloatCollector* fc)
            {
              if (fc)
              {
                void* data = fc;
                VALUE ret = TypedData_Wrap_Struct(mWxRichTextFloatCollector, &__wxRichTextFloatCollector_type, data);
                return ret;
              }
              else
                return Qnil;
            } 
  
            extern wxRichTextFloatCollector* _wxRuby_Unwrap_wxRichTextFloatCollector(VALUE rbfc)
            {
              if (NIL_P(rbfc))
                return nullptr;
              else
              {
                void *data = 0;
                TypedData_Get_Struct(rbfc, void, &__wxRichTextFloatCollector_type, data);
                return reinterpret_cast<wxRichTextFloatCollector*> (data);
              }
            }
  
            extern bool _wxRuby_Is_wxRichTextFloatCollector(VALUE rbfc)
            {
              return rb_typeddata_is_kind_of(rbfc, &__wxRichTextFloatCollector_type) == 1;
            } 
            __HEREDOC

          spec.ignore 'wxRichTextParagraph::MoveToList',
                      'wxRichTextParagraph::MoveFromList',
                      ignore_doc: false
          spec.map 'wxList& list' => 'Array<Wx::RTC::RichTextObject>', swig: false do
            map_in
          end
          spec.add_extend_code 'wxRichTextParagraph', <<~__CODE
            void move_to_list(wxRichTextObject *wx_rto, VALUE rb_list)
            {
              if (TYPE(rb_list) != T_ARRAY)
              {
                rb_raise(rb_eArgError, "Expected Array for list");
              }
              wxList wx_lst;
              $self->MoveToList(wx_rto, wx_lst);
              for (const wxObject* wx_obj : wx_lst)
              {
                VALUE rb_rto = wxRuby_RichTextObject2Ruby(dynamic_cast<const wxRichTextObject*> (wx_obj), SWIG_POINTER_OWN);
                rb_ary_push(rb_list, rb_rto);
              }
            }
    
            void move_from_list(VALUE rb_list)
            {
              if (TYPE(rb_list) != T_ARRAY)
              {
                rb_raise(rb_eArgError, "Expected Array for list");
              }
              wxList wx_lst;
              for (int i=0; i<RARRAY_LEN(rb_list) ;++i)
              {
                void *ptr;
                int res = SWIG_ConvertPtr(rb_ary_entry(rb_list, i), &ptr,SWIGTYPE_p_wxRichTextObject, SWIG_POINTER_DISOWN);
                if (!SWIG_IsOK(res)) 
                {
                  rb_raise(rb_eArgError, "Expected Array of Wx::RTC::RichTextObject for list"); 
                }
                wxRichTextObject* wx_rto = reinterpret_cast< wxRichTextObject * >(ptr);
                wx_lst.push_back(wx_rto);
              }
              $self->MoveFromList(wx_lst);
            }
            __CODE

          spec.do_not_generate(:typedefs, :variables, :enums, :defines, :functions)
        end
      end

    end

  end

end
