###
# wxRuby3 PGProperty typemap definition
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative '../core/mapping'

module WXRuby3

  module Typemap

    # Typemaps for converting returned PGEditor references to
    # either the correct wxRuby class
    module PGEditor

      include Typemap::Module

      define do

        map 'wxPGEditor*' => 'Wx::PG::PGEditor' do
          add_header_code <<~__CODE
            #include <wx/propgrid/editors.h>
            extern VALUE wxRuby_WrapWxPGEditorInRuby(const wxPGEditor *wx_pp);
            __CODE
          map_out code: '$result = wxRuby_WrapWxPGEditorInRuby($1);'
          map_directorin code: '$input = wxRuby_WrapWxPGEditorInRuby($1);'
        end

      end

    end

  end

end
