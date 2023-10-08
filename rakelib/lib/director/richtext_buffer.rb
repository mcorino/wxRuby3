# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './richtext_object'

module WXRuby3

  class Director

    class RichTextBuffer < RichTextObject

      include Typemap::RichText

      def setup
        super
        spec.disable_proxies
        spec.items.replace %w[
          wxRichTextBuffer
          ]
        spec.gc_as_object 'wxRichTextBuffer'
        spec.override_inheritance_chain('wxRichTextBuffer', %w[wxObject])
        spec.ignore %w[
          wxRichTextBuffer::GetBatchedCommand
          wxRichTextBuffer::GetCommandProcessor
          ]
        spec.disown 'wxRichTextFileHandler* handler'
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
        spec.do_not_generate(:typedefs, :variables, :enums, :defines, :functions)
      end
    end # class RichTextBuffer

  end # class Director

end # module WXRuby3
