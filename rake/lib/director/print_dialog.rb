###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class PrintDialog < Director

      include Typemap::PrintData

      def setup
        super
        spec.no_proxy 'wxPrintDialog::GetPrintDC' # do not think this is really useful
        spec.new_object 'wxPrintDialog::GetPrintDC'
        spec.suppress_warning(473,
                              'wxPrintDialog::GetPrintData',
                              'wxPrintDialog::GetPrintDialogData')
      end
    end # class PrintDialog

  end # class Director

end # module WXRuby3
