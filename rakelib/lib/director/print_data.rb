# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class PrintData < Director

      def setup
        super
        spec.gc_as_untracked
        spec.disable_proxies # fixed and final data structures
        spec.items << 'wxPrintDialogData' << 'wxPageSetupDialogData'
        spec.ignore 'wxPrintDialogData::SetSetupDialog' # deprecated since 2.5.4
        # only keep the const version
        spec.ignore 'wxPageSetupDialogData::GetPrintData'
        spec.regard 'wxPageSetupDialogData::GetPrintData() const'
        # for GetPrintData methods
        spec.map 'wxPrintData&' => 'Wx::PrintData' do
          map_out code: '$result = SWIG_NewPointerObj(SWIG_as_voidptr(new wxPrintData(*$1)), SWIGTYPE_p_wxPrintData, SWIG_POINTER_OWN);'
        end
        spec.swig_import 'swig/classes/include/wxDefs.h'
      end
    end # class PrintData

  end # class Director

end # module WXRuby3
