# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 client data typemap definition
###

require_relative '../core/mapping'

module WXRuby3

  module Typemap

    module ClientData

      include Typemap::Module

      define do

        map 'wxClientData *' => 'Object' do
          add_header_code <<~__CODE
            #include "wxruby-ClientData.h"
            __CODE
          map_in code: '$1 = NIL_P($input) ? nullptr : new wxRubyClientData($input);'
          map_out code: <<~__CODE
            $result = Qnil;
            if ($1)
            {
              wxRubyClientData* rbcd = dynamic_cast<wxRubyClientData*> ($1);
              if (rbcd) $result = rbcd->GetData();
            }
          __CODE

          map_typecheck precedence: 'POINTER', code: '$1 = true;'
        end

      end

    end

  end

end
