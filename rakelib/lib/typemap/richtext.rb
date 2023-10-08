# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 Common typemap definitions
###

require_relative '../core/mapping'

module WXRuby3

  module Typemap

    # Shared features used by the RichText classes
    module RichText

      include Typemap::Module

      define do

        # The wxWidgets RichText API in several places represents and returns
        # ranges of text selections with a special class. It doesn't add
        # anything much that Ruby's own range class doesn't, so deal with using
        # typemaps
        map 'wxRichTextRange&' => 'Range' do

          map_in code: <<~__CODE
            int start = NUM2INT( rb_funcall( $input, rb_intern("begin"), 0));
            int end   = NUM2INT( rb_funcall( $input, rb_intern("end"), 0));
            wxRichTextRange rng = wxRichTextRange(start, end);
            $1 = &rng;
            __CODE

          map_typecheck precedence: 1, code: '$1 = ( CLASS_OF($input) == rb_cRange );'

          map_out code: '$result = rb_range_new (LONG2NUM($1->GetStart()),LONG2NUM($1->GetEnd()),0);'

          map_directorin code: '$input = rb_range_new (LONG2NUM($1.GetStart()),LONG2NUM($1.GetEnd()),0);'

        end

        map 'wxRichTextRange' => 'Range' do

          map_out code: '$result = rb_range_new (LONG2NUM($1.GetStart()),LONG2NUM($1.GetEnd()),0);'

          map_directorout code: <<~__CODE
            int start = NUM2INT( rb_funcall( $input, rb_intern("begin"), 0));
            int end   = NUM2INT( rb_funcall( $input, rb_intern("end"), 0));
            $result = wxRichTextRange(start, end);
            __CODE

        end

        map 'const wxRichTextRangeArray &' => 'Array<Range>' do

          map_in temp: 'wxRichTextRangeArray tmp', code: <<~__CODE
            if (TYPE($input) == T_ARRAY)
            {
              for (int i=0; i<RARRAY_LEN($input) ;++i)
              {
                VALUE rb_range = rb_ary_entry($input, i);
                int start = NUM2INT( rb_funcall(rb_range, rb_intern("begin"), 0));
                int end   = NUM2INT( rb_funcall(rb_range, rb_intern("end"), 0));
                tmp.Add(wxRichTextRange(start, end));
              }
              $1 = &tmp;
            }
            else
            {
              rb_raise(rb_eArgError, "Expected Array of Range for %d", $argnum-1);
            }
            __CODE

          map_out code: <<~__CODE
            $result = rb_ary_new();
            for (size_t i = 0; i < $1->GetCount(); i++)
            {
              const wxRichTextRange& range = $1->Item(i);
              rb_ary_push($result, rb_range_new (LONG2NUM(range.GetStart()),LONG2NUM(range.GetEnd()),0));
            }
            __CODE

          map_typecheck precedence: 'POINTER', code: '$1 = TYPE($input) == T_ARRAY;'

        end

        map 'wxRichTextRangeArray' => 'Array<Range>' do

          map_out code: <<~__CODE
            $result = rb_ary_new();
            for (size_t i = 0; i < $1.GetCount(); ++i)
            {
              const wxRichTextRange& range = $1.Item(i);
              rb_ary_push($result, rb_range_new (LONG2NUM(range.GetStart()),LONG2NUM(range.GetEnd()),0));
            }
            __CODE

        end

        map 'wxRichTextObject *' => 'Wx::RTC::RichTextObject' do

          map_out code: '$result = wxRuby_RichTextObject2Ruby($1);'

        end

        map 'wxRichTextObject **' => 'Wx::RTC::RichTextObject' do

          map_in ignore: true, temp: 'wxRichTextObject * tmp', code: '$1 = &tmp;'

          map_argout code: '$result = SWIG_Ruby_AppendOutput($result, wxRuby_RichTextObject2Ruby(tmp$argnum));'

        end

        map 'wxArrayInt * partialExtents' => 'Array,nil' do
          map_in temp: 'wxArrayInt tmp, VALUE rb_arg', code: '$1 = NIL_P($input) ? nullptr : &tmp; rb_arg = $input;'
          map_argout code: <<~__CODE
              if (!NIL_P(rb_arg$argnum))
              {
                for (size_t i=0; i<tmp$argnum.GetCount() ;++i)
                {
                  rb_ary_push(rb_arg$argnum, INT2NUM(tmp$argnum.Item(i)));
                }
              }
              __CODE
        end

        # Used as out parameters by some other selection-getting methods
        map_apply 'int *OUTPUT' => [ 'long * from' , 'long * to', 'long& textPosition', 'long& wrapPosition' ]

        map 'bool * recurse' => 'Boolean' do

          map_in temp: 'bool recurse', code: 'recurse = ($input == Qtrue); $1 = &recurse;'

          map_argout code: '$result = SWIG_Ruby_AppendOutput($result, recurse$argnum ? Qtrue : Qfalse);'

        end

        map 'wxRichTextFloatCollector*' => 'Wx::RTC::RichTextFloatCollector' do
          add_header_code <<~__CODE
            extern VALUE _wxRuby_Wrap_wxRichTextFloatCollector(wxRichTextFloatCollector* fc);
            extern wxRichTextFloatCollector* _wxRuby_Unwrap_wxRichTextFloatCollector(VALUE rbfc);
            extern bool _wxRuby_Is_wxRichTextFloatCollector(VALUE rbfc);
            __CODE
          map_in code: '$1 = _wxRuby_Unwrap_wxRichTextFloatCollector($input);'
          map_out code: '$result = _wxRuby_Wrap_wxRichTextFloatCollector($1);'
          map_typecheck code: '$1 = _wxRuby_Is_wxRichTextFloatCollector($input);'
        end
        
      end # define

    end # RichText

  end # Typemap

end # WXRuby3
