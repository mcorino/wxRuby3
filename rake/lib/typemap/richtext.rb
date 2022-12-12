###
# wxRuby3 Common typemap definitions
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative '../core/mapping'

module WXRuby3

  module Typemap

    # Shared features used by the RichText classes
    module RichText

      include Typemap::Module

      def self.on_include(including_mod)
        # Used by several classes to load and save rich text content to files
        # and streams.
        including_mod.include(Typemap::IOStreams)
      end

      define do

        # The wxWidgets RichText API in several places represents and returns
        # ranges of text selections with a special class. It doesn't add
        # anything much that Ruby's own range class doesn't, so deal with using
        # typemaps
        map 'wxRichTextRange&' do

          map_type 'Range'

          map_in code: <<~__CODE
            int start = NUM2INT( rb_funcall( $input, rb_intern("begin"), 0));
            int end   = NUM2INT( rb_funcall( $input, rb_intern("end"), 0));
            wxRichTextRange rng = wxRichTextRange(start, end);
            $1 = &rng;
            __CODE

          map_typecheck code: '$1 = ( CLASS_OF($input) == rb_cRange );'

          map_out code: '$result = rb_range_new (LONG2NUM($1->GetStart()),LONG2NUM($1->GetEnd()),0);'

        end

        # Used as in/out parameters by some other selection-getting methods
        map_apply 'int *OUTPUT' => [ 'long * from' , 'long * to' ]

        # For some reason, some methods in RichTextCtrl accept and return
        # TextAttrEx, some RichTextAttr and some both. For those that support
        # both, the TextAttrEx versions are ignored in the class's individual
        # interface file. The typemaps below convert those that only accept or
        # return TextAttrEx in C++ to accept/return Wx::RichTextAttr objects
        # from Ruby, so the TextAttrEx class remains unported.
        map 'wxTextAttrEx&' do

          map_type 'Wx::RichTextAttr'

          map_in code: <<~__CODE
            void *arg = 0;
            int result = SWIG_ConvertPtr($input, &arg, SWIGTYPE_p_wxRichTextAttr, 0);
            wxRichTextAttr* rich_attr = reinterpret_cast< wxRichTextAttr* >(arg);
            wxTextAttrEx attr_ex(*rich_attr);
            $1 = &attr_ex;
            __CODE

          map_typecheck code: <<~__CODE
            void *arg = 0;
            int result = SWIG_ConvertPtr($input, &arg, SWIGTYPE_p_wxRichTextAttr, 0);
            $1 = SWIG_CheckState(res);
            __CODE

          map_out code: <<~__CODE
            wxRichTextAttr* rta = new wxRichTextAttr($1);
            $result = SWIG_NewPointerObj(rta, SWIGTYPE_p_wxRichTextAttr, SWIG_POINTER_OWN);
            __CODE

        end

      end # define

    end # RichText

  end # Typemap

end # WXRuby3
