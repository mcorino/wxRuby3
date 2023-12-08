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

        map 'wxObject *userData' => 'Object' do
          add_header_code <<~__CODE
            #include "wxruby-ClientData.h"
            __CODE
          map_in code: '$1 = NIL_P($input) ? nullptr : new wxRubyUserData($input);'

          map_typecheck precedence: 'POINTER', code: '$1 = true;'
        end

        # WxUserDataObject must be typedef for wxObject*
        map 'WxUserDataObject' => 'Object' do

          map_out code: <<~__CODE
            $result = Qnil;
            if ($1)
            {
              wxRubyUserData* rbud = dynamic_cast<wxRubyUserData*> ($1);
              if (rbud) $result = rbud->GetData();
            }
          __CODE

        end

      end

    end

  end

end
