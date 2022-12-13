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

          map_typecheck precedence: 1, code: '$1 = ( CLASS_OF($input) == rb_cRange );'

          map_directorin code: '$input = rb_range_new (LONG2NUM($1.GetStart()),LONG2NUM($1.GetEnd()),0);'

        end

        map 'wxRichTextRange' do

          map_type 'Range'

          map_out code: '$result = rb_range_new (LONG2NUM($1.GetStart()),LONG2NUM($1.GetEnd()),0);'

          map_directorout code: <<~__CODE
            int start = NUM2INT( rb_funcall( $input, rb_intern("begin"), 0));
            int end   = NUM2INT( rb_funcall( $input, rb_intern("end"), 0));
            $result = wxRichTextRange(start, end);
            __CODE

        end

        # Used as in/out parameters by some other selection-getting methods
        map_apply 'int *OUTPUT' => [ 'long * from' , 'long * to' ]

      end # define

    end # RichText

  end # Typemap

end # WXRuby3
