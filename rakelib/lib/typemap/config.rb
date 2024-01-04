# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 Common typemap definitions
###

require_relative '../core/mapping'

module WXRuby3

  module Typemap

    # Deals with GetAllFormats
    module ConfigBase

      include Typemap::Module

      define do

        map 'wxConfigBase*' => 'Wx::ConfigBase' do

          map_in code: <<~__CODE
            $1 = nullptr;
            if (!NIL_P($input))
            {
              $1 = wxRuby_Ruby2ConfigBase($input);
              if ($1 == nullptr)
              {
                VALUE msg = rb_inspect($input);
                rb_raise(rb_eArgError, "Expected Wx::ConfigBase or Hash for %d but got %s",
                                        $argnum-1, StringValuePtr(msg));
              }
            }
            __CODE

          map_typecheck precedence: 'POINTER', code: <<~__CODE
            $1 = wxRuby_IsRubyConfig($input);
            __CODE


          map_directorin code: <<~__CODE
            $input = wxRuby_ConfigBase2Ruby($1);
            __CODE

          map_out code: <<~__CODE
            $result = wxRuby_ConfigBase2Ruby($1);
            __CODE

          map_directorout code: <<~__CODE
            $result = wxRuby_Ruby2ConfigBase($1); 
            __CODE

        end

      end

    end

  end

end
