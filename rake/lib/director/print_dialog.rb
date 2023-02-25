###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class PrintDialog < Director

      def setup
        super
        spec.no_proxy 'wxPrintDialog::GetPrintDC' # do not think this is really useful
        spec.new_object 'wxPrintDialog::GetPrintDC'
        # make PrintDialog GC-safe
        spec.ignore 'wxPrintDialog::GetPrintData',
                    'wxPrintDialog::GetPrintDialogData'
        spec.add_extend_code 'wxPrintDialog', <<~__HEREDOC
          wxPrintData* GetPrintData()
          { return new wxPrintData(self->GetPrintData()); }
          void SetPrintData(const wxPrintData& pd)
          { self->GetPrintData() = pd; }
          wxPrintDialogData* GetPrintDialogData()
          { return new wxPrintDialogData(self->GetPrintDialogData()); }
          void SetPrintDialogData(const wxPrintDialogData& pd)
          { self->GetPrintDialogData() = pd; }
          __HEREDOC
        spec.new_object 'wxPrintDialog::GetPrintData',
                        'wxPrintDialog::GetPrintDialogData'
      end
    end # class PrintDialog

  end # class Director

end # module WXRuby3
