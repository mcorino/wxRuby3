###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class PrintData < Director

      include Typemap::PrintData

      def setup
        super
        spec.gc_as_temporary
        spec.disable_proxies # fixed and final data structures
        spec.items << 'wxPrintDialogData' << 'wxPageSetupDialogData'
        spec.ignore 'wxPrintDialogData::SetSetupDialog' # deprecated since 2.5.4
        spec.swig_import 'swig/classes/include/wxDefs.h'
      end
    end # class PrintData

  end # class Director

end # module WXRuby3
