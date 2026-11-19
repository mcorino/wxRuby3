# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 Common typemap definitions
###

require_relative '../core/mapping'

module WXRuby3

  module Typemap

    # These typemaps are used by DataView classes to convert wxDataViewItem
    # instances into the actual Ruby id objects
    module DataViewItem

      include Typemap::Module

      define do

        map 'wxDataViewItem&' => '::Integer' do

          map_in temp: 'wxDataViewItem tmpId', code: <<~__CODE
            if ($input != Qnil) tmpId = wxDataViewItem((void*)wxUIntPtr(NUM2ULL($input)));
            $1 = &tmpId;
            __CODE

          map_directorin code: '$input = $1.IsOk() ? ULL2NUM(wxUIntPtr($1.GetID())) : Qnil;'

          map_typecheck precedence: 'string', code: '$1 = true;'
        end

        map 'wxDataViewItem' => '::Integer' do

          map_in temp: 'wxDataViewItem tmpId', code: <<~__CODE
            if ($input != Qnil) tmpId = wxDataViewItem((void*)wxUIntPtr(NUM2ULL($input)));
            $1 = tmpId;
            __CODE

          map_directorin code: '$input = $1.IsOk() ? ULL2NUM(wxUIntPtr($1.GetID())) : Qnil;'

          map_out code: '$result = $1.IsOk() ? ULL2NUM(wxUIntPtr($1.GetID())) : Qnil;'

          map_directorout temp: 'wxDataViewItem tmpId', code: <<~__CODE
            if ($input != Qnil) tmpId = wxDataViewItem((void*)wxUIntPtr(NUM2ULL($input)));
            $result = tmpId;
          __CODE

          map_typecheck precedence: 'string', code: '$1 = true;'
        end

        map 'const wxDataViewItemArray&' => '::Array<::Integer>' do

          map_in temp: 'wxDataViewItemArray tmp_arr', code: <<~__CODE
            if (RTEST($input))
            {
              if (TYPE($input) == T_ARRAY)
              {
                for (int i = 0; i < RARRAY_LEN($input); i++)
                {
                  VALUE val = rb_ary_entry($input, i);
                  tmp_arr.Add(RTEST(val) ? wxDataViewItem((void*)wxUIntPtr(NUM2ULL(val))) : wxDataViewItem());
                }
              }
              else
              {
                const char* msg;
                VALUE rb_msg;
                rb_msg = rb_inspect($input);
                msg = StringValuePtr(rb_msg);
                rb_raise(rb_eTypeError, "$symname : expected Array<Object> for $argnum but got %s",
                         msg);
              }
            }
            $1 = &tmp_arr;
            __CODE

          map_directorin code: <<~__CODE
            $input = rb_ary_new();
            for (size_t n=0; n <$1.GetCount() ;n++)
            {
              wxDataViewItem wx_itm = $1.Item(n);
              rb_ary_push($input, wx_itm.IsOk() ? ULL2NUM(wxUIntPtr(wx_itm.GetID())) : Qnil);
            }
            __CODE

        end

      end # define

    end # DataViewItem

  end # Typemap

end # WXRuby3
