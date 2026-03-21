# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 Common typemap definitions
###

require_relative '../core/mapping'

module WXRuby3

  module Typemap

    module MBConv

      include Typemap::Module

      # wxMBConv classes are used for string text encoding conversion.
      # We do not want to map these in wxRuby3 though as that serves little purpose there.
      # So there are wxRuby3 specific versions implemented that get mapped to the actual
      # wxw instances by the type mappings below.

      define do

        map 'const wxMBConv&' => 'Wx::MBConv' do

          add_header_code <<~__CODE
            WXRUBY_EXPORT std::unique_ptr<wxMBConv> wxRuby_MBConv2wxMBConv(VALUE rb_val);
            __CODE

          map_in temp: 'std::unique_ptr<wxMBConv> tmp_mbc',
                 code: <<~__CODE
              tmp_mbc = wxRuby_MBConv2wxMBConv($input);
              if (!tmp_mbc)
              {
                rb_raise(rb_eArgError, "Invalid MBConv value for %i", $argnum-1);
              }
              else
              {
                $1 = tmp_mbc.get();
              }
            __CODE

          map_typecheck precedence: 'POINTER', code: <<~__CODE
            std::unique_ptr<wxMBConv> mbc = wxRuby_MBConv2wxMBConv($input);
            $1 = mbc ? true : false;
            __CODE

        end

      end

    end

  end

end
