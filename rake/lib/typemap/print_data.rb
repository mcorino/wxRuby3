###
# wxRuby3 Common typemap definitions
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative '../core/mapping'

module WXRuby3

  module Typemap

    module PrintData

      include Typemap::Module

      # The various print data structures are invariably returned by reference in wxWidgets.
      # Since these references are from private members of temporary objects this does not make
      # for very safe storage of these references in Ruby and would often force us to make
      # explicit copies which is not the Ruby "way".
      # Therefor we create a series of mappings to force print data returns to be 'by value' like
      # for wxSize, wxPoint etc.
      define do

        map 'wxPrintData &' => 'Wx::Print::PrintData' do

          map_out code: <<~__CODE
            vresult = SWIG_NewPointerObj((new wxPrintData(*result)), SWIGTYPE_p_wxPrintData, SWIG_POINTER_OWN |  0 );
            __CODE

        end

        map 'wxPrintDialogData &' => 'Wx::Print::PrintDialogData' do

          map_out code: <<~__CODE
            vresult = SWIG_NewPointerObj((new wxPrintDialogData(*result)), SWIGTYPE_p_wxPrintDialogData, SWIG_POINTER_OWN |  0 );
          __CODE

        end


        map 'wxPageSetupDialogData &' => 'Wx::Print::PageSetupDialogData' do

          map_out code: <<~__CODE
            vresult = SWIG_NewPointerObj((new wxPageSetupDialogData(*result)), SWIGTYPE_p_wxPageSetupDialogData, SWIG_POINTER_OWN |  0 );
          __CODE

        end
      end # define

    end # PrintData

  end # Typemap

end # WXRuby3
