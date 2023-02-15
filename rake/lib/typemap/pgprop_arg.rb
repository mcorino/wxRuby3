###
# wxRuby3 PGPropArg typemap definitions
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative '../core/mapping'

module WXRuby3

  module Typemap

    module PGPropArg

      include Typemap::Module

      # provide automagic conversion of simple types to PGPropArg arguments
      define do

        map 'const wxPGPropArgCls&' => 'String,Wx::PG::PGProperty' do
          map_in temp: 'wxPGPropArgCls temp = (wxPGProperty *)0', code: <<~__CODE
            if (!NIL_P($input))
            {
              if (TYPE($input) == T_STRING)
              {
                temp = wxPGPropArgCls(RSTR_TO_WXSTR($input));
              }
              else if (TYPE($input) == T_DATA)
              {
                VALUE rb_klass = rb_const_get(mWxPG, rb_intern("PGProperty"));
                if (rb_obj_is_kind_of($input, rb_klass))
                {
                  swig_type_info* swig_type = wxRuby_GetSwigTypeForClass(rb_klass);
                  wxPGProperty *pgprop = (wxPGProperty *)0;
                  SWIG_ConvertPtr($input, SWIG_as_voidptrptr(&pgprop), swig_type, SWIG_POINTER_DISOWN);
                  temp = wxPGPropArgCls(pgprop);
                }
                else
                {
                  VALUE msg = rb_inspect($input);
                  rb_raise(rb_eArgError, "Expected Wx::PGProperty for $argnum but got %s",
                                          StringValuePtr(msg));
                }
              }
            }
            $1 = &temp;
            __CODE
          map_directorin code: <<~__CODE
            if ($1.HasName())
            {
              $input = WXSTR_TO_RSTR($1.GetName());
            }
            else
            {
              $input = wxRuby_WrapWxPGPropertyInRuby($1.GetPtr0());
            }
            __CODE
        end

        # doc-only
        map 'wxPGPropArg' => 'String,Wx::PG::PGProperty', swig: false do
          map_in code: ''
        end

      end

    end # PGPropArg

  end # Typemap

end # WXRuby3
