# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxComboPopup typemap definition
###

require_relative '../core/mapping'

module WXRuby3

  module Typemap

    module ComboPopup

      include Typemap::Module

      define do

        # for DoSetPopupControl
        map 'wxComboPopup* popup' => 'Wx::ComboPopup,nil' do

          add_header_code <<~__CODE
            #include <wx/combo.h>
            
            WXRUBY_EXPORT wxComboPopup* wxRuby_ComboPopupFromRuby(VALUE popup);
            WXRUBY_EXPORT VALUE wxRuby_ComboPopupToRuby(wxComboPopup* popup);
            __CODE

          map_in code: '$1 = wxRuby_ComboPopupFromRuby($input);'

          map_directorin code: '$input = wxRuby_ComboPopupToRuby($1);'
        end

      end

    end

  end

end
