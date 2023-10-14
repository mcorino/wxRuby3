# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './richtext_object'

module WXRuby3

  class Director

    class RichTextBox < RichTextObject

      include Typemap::RichText

      def setup
        super
        spec.items << 'wxRichTextCell' << 'wxRichTextTable'
        spec.include 'wx/richtext/richtextstyles.h'

        spec.map_apply 'int * OUTPUT' => ['int &row', 'int &col']

        spec.map 'wxPosition' => 'Array(Integer,Integer)' do

          map_out code: <<~__CODE
            $result = rb_ary_new();
            rb_ary_push($result, INT2NUM($1.GetRow()));
            rb_ary_push($result, INT2NUM($1.GetColumn()));
            __CODE

        end

        spec.map 'const wxRichTextObjectPtrArrayArray &' => 'Array<Array<Wx::RTC::RichTextObject>>' do

          map_out code: <<~__CODE
            $result = rb_ary_new();
            for (size_t r=0; r<$1->GetCount() ;++r)
            {
              VALUE rb_r_arr = rb_ary_new();
              rb_ary_push($result, rb_r_arr);
              const wxRichTextObjectPtrArray &r_arr = $1->Item(r);
              for (size_t c=0; c<r_arr.GetCount() ;++c)
              {
                rb_ary_push(rb_r_arr, wxRuby_RichTextObject2Ruby(r_arr.Item(c), 0));
              }
            }
            __CODE

        end

        spec.do_not_generate(:typedefs, :variables, :enums, :defines, :functions)
      end

    end

  end

end
