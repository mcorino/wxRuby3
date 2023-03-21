###
# wxRuby3 PGProperty typemap definition
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative '../core/mapping'

module WXRuby3

  module Typemap

    # Typemaps for converting returned PGProperty references to
    # either the correct wxRuby class
    module PGProperty

      include Typemap::Module

      define do

        map 'wxPGProperty*' => 'Wx::PG::PGProperty' do
          add_header_code <<~__CODE
            #include <wx/propgrid/property.h>
            extern VALUE wxRuby_WrapWxPGPropertyInRuby(const wxPGProperty *wx_pp);
            __CODE
          map_out code: '$result = wxRuby_WrapWxPGPropertyInRuby($1);'
          map_directorin code: '$input = wxRuby_WrapWxPGPropertyInRuby($1);'
        end

      end

    end

  end

end
