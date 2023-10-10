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
        spec.items << 'wxRichTextFontTable' << 'wxRichTextFieldType' << 'wxRichTextFieldTypeStandard'
        spec.make_abstract 'wxRichTextFieldType'
        spec.no_proxy 'wxRichTextFontTable'
        spec.include 'wx/richtext/richtextstyles.h'
        spec.ignore %w[
          wxRichTextBuffer::GetBatchedCommand
          wxRichTextBuffer::GetCommandProcessor
          wxRichTextBuffer::SubmitAction
          wxRichTextBuffer::GetHandlers
          wxRichTextBuffer::GetFieldTypes
          wxRichTextBuffer::GetRenderer
          wxRichTextBuffer::SetRenderer
          wxRichTextBuffer::GetDrawingHandlers
          wxRichTextBuffer::AddDrawingHandler
          wxRichTextBuffer::InsertDrawingHandler
          wxRichTextBuffer::RemoveDrawingHandler
          wxRichTextBuffer::FindDrawingHandler
          wxRichTextBuffer::CleanUpDrawingHandlers
          ]
        spec.disown 'wxRichTextFileHandler* handler'
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

        spec.do_not_generate(:typedefs, :variables, :enums, :defines, :functions)
      end
    end # class RichTextBuffer

  end # class Director

end # module WXRuby3
