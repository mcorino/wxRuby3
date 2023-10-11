# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './richtext_paragraph_layout_box'

module WXRuby3

  class Director

    class RichTextBuffer < RichTextParagraphLayoutBox

      include Typemap::RichText

      def setup
        super
        spec.items << 'wxRichTextFontTable' << 'wxRichTextFieldType' << 'wxRichTextFieldTypeStandard' << 'wxRichTextDrawingHandler'
        spec.make_abstract 'wxRichTextFieldType'
        spec.no_proxy 'wxRichTextFontTable'
        spec.include 'wx/richtext/richtextstyles.h'
        spec.ignore %w[
          wxRichTextBuffer::GetBatchedCommand
          wxRichTextBuffer::GetCommandProcessor
          wxRichTextBuffer::SubmitAction
          wxRichTextBuffer::GetHandlers
          wxRichTextBuffer::GetFieldTypes
          wxRichTextBuffer::GetDrawingHandlers
          wxRichTextBuffer::GetRenderer
          wxRichTextBuffer::SetRenderer
          ]
        spec.disown 'wxRichTextFileHandler* handler',
                    'wxRichTextDrawingHandler *handler',
                    'wxRichTextFieldType *fieldType'
        spec.add_extend_code 'wxRichTextBuffer', <<~__HEREDOC
          static VALUE each_handler()
          {
            VALUE rc = Qnil;
            if (rb_block_given_p())
            {
              wxList& handlers = wxRichTextBuffer::GetHandlers();
              for (wxList::compatibility_iterator node = handlers.GetFirst();
                    node; node = node->GetNext())
              {
                wxRichTextFileHandler *handler = (wxRichTextFileHandler *) node->GetData();
                rc = rb_yield (SWIG_NewPointerObj(SWIG_as_voidptr(handler), SWIGTYPE_p_wxRichTextFileHandler, 0));
              }
            }
            return rc;  
          }

          static VALUE each_field_type()
          {
            VALUE rc = Qnil;
            if (rb_block_given_p())
            {
              wxRichTextFieldTypeHashMap& map = wxRichTextBuffer::GetFieldTypes();
              wxRichTextFieldTypeHashMap::const_iterator it = map.begin();
              for (; it != map.end() ;++it)
              {
                wxRichTextFieldType *ft = it->second;
                rc = rb_yield (SWIG_NewPointerObj(SWIG_as_voidptr(ft), SWIGTYPE_p_wxRichTextFieldType, 0));
              }
            }
            return rc;  
          }

          static VALUE each_drawing_handler()
          {
            VALUE rc = Qnil;
            if (rb_block_given_p())
            {
              wxList& handlers = wxRichTextBuffer::GetDrawingHandlers();
              for (wxList::compatibility_iterator node = handlers.GetFirst();
                    node; node = node->GetNext())
              {
                wxRichTextDrawingHandler *handler = (wxRichTextDrawingHandler *) node->GetData();
                rc = rb_yield (SWIG_NewPointerObj(SWIG_as_voidptr(handler), SWIGTYPE_p_wxRichTextDrawingHandler, 0));
              }
            }
            return rc;  
          }

          __HEREDOC
        # for GetExtWildcard
        spec.map 'wxArrayInt* types' => 'Array,nil' do

          map_in temp: 'wxArrayInt tmp, VALUE rb_types', code: <<~__CODE
            rb_types = $input;
            if (!NIL_P(rb_types)) 
            {
              if (TYPE(rb_types) == T_ARRAY)
              {
                $1 = &tmp;
              }
              else
              {
                SWIG_exception_fail(SWIG_TypeError, Ruby_Format_TypeError( "", "Array","$symname", $argnum, $input ));
              } 
            }
            __CODE

          map_argout by_ref: true, code: <<~__CODE
            if (!NIL_P(rb_types$argnum))
            {
              for (size_t i = 0; i < $1->GetCount(); i++)
              {
                rb_ary_push(rb_types$argnum,INT2NUM( $1->Item(i) ) );
              }
            }
            __CODE

        end

        # for wxRichTextFieldType::GetRangeSize
        spec.map 'int & descent' => 'Integer' do

          map_in temp: 'int tmp', code: 'tmp = NUM2INT($input); $1 = &tmp;'

          map_argout code: '$result = SWIG_Ruby_AppendOutput($result, INT2NUM(tmp$argnum));'

          map_directorin code: '$input = INT2NUM($1);'

          map_directorargout code: <<~__CODE
            if(output != Qnil)
            {
              $1 = NUM2INT(output);
            }
            else
            {
              $1 = 0;
            }
            __CODE

        end

        # for wxRichTextDrawingHandler::GetVirtualSubobjectAttributes
        spec.map 'wxArrayInt & positions' => 'Array' do

          map_in temp: 'wxArrayInt tmp, VALUE rb_pos', code: <<~__CODE
            rb_pos = $input;
            if (TYPE(rb_pos) == T_ARRAY)
            {
              $1 = &tmp;
            }
            else
            {
              SWIG_exception_fail(SWIG_TypeError, Ruby_Format_TypeError( "", "Array","$symname", $argnum, $input ));
            } 
            __CODE

          map_argout by_ref: true, code: <<~__CODE
            for (size_t i = 0; i < $1->GetCount(); i++)
            {
              rb_ary_push(rb_pos$argnum,INT2NUM( $1->Item(i) ) );
            }
            __CODE

          map_directorin code: 'VALUE rb_int_arr = $input = rb_ary_new();'
          map_directorargout code: <<~__CODE
            for (int i=0; i<RARRAY_LEN(rb_int_arr) ;++i)
            {
              $1.Add(NUM2INT(rb_ary_entry(rb_int_arr, i)));
            }
            output = Qnil;
            __CODE

        end
        spec.map 'wxRichTextAttrArray & attributes' => 'Array' do

          map_in temp: 'wxRichTextAttrArray arr, VALUE rb_arr', code: <<~__CODE
            if (TYPE($input) == T_ARRAY)
            {
              $1 = &arr;
              rb_arr = $input;
            }
            else
            {
              rb_raise(rb_eArgError, "Expected an Array for %d", $argnum-1);
            }
            __CODE

          map_argout by_ref: true, code: <<~__CODE
            for (size_t i=0; i<arr$argnum.GetCount() ;++i)
            {
              wxRichTextAttr* wx_rta = new wxRichTextAttr(arr$argnum.Item(i));
              rb_ary_push(rb_arr$argnum, SWIG_NewPointerObj(SWIG_as_voidptr(wx_rta), SWIGTYPE_p_wxRichTextAttr, SWIG_POINTER_OWN));
            }
            __CODE

          map_directorin code: 'VALUE rb_attr_arr = $input = rb_ary_new();'
          map_directorargout code: <<~__CODE
            for (int i=0; i<RARRAY_LEN(rb_attr_arr) ;++i)
            {
              void *ptr;
              int res = SWIG_ConvertPtr(rb_ary_entry(rb_int_arr, i), &ptr,SWIGTYPE_p_wxRichTextAttr, 0);
              if (!SWIG_IsOK(res)) 
              {
                Swig::DirectorTypeMismatchException::raise(SWIG_ErrorType(SWIG_ArgError(res)), "in output value of type '""Wx::RTC::RichTextAttr""'");
              }
              wxRichTextAttr* wx_att = static_cast< wxRichTextAttr* >(ptr);
              $1.Add(*wx_att);
            }
            output = Qnil;
            __CODE

        end

        spec.do_not_generate(:typedefs, :variables, :enums, :defines, :functions)
      end
    end # class RichTextBuffer

  end # class Director

end # module WXRuby3
