###
# wxRuby3 PGProperty typemap definition
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative '../core/mapping'

module WXRuby3

  module Typemap

    # Typemaps for converting returned PGCell references to
    # either the correct wxRuby class
    module PGCell

      include Typemap::Module

      define do

        map 'wxPGCell&' => 'Wx::PG::PGCell' do
          add_header_code <<~__CODE
            #include <wx/propgrid/property.h>
            extern VALUE wxRuby_WrapWxPGCellInRuby(const wxPGCell *wx_pc);
            __CODE
          map_out code: '$result = wxRuby_WrapWxPGCellInRuby($1);'
          map_directorin code: '$input = wxRuby_WrapWxPGCellInRuby($1);'
        end

      end

    end

  end

end
