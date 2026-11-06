# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class PrintDialog < Director

      def setup
        super
        spec.no_proxy 'wxPrintDialog::GetPrintDC' # do not think this is really useful
        spec.new_object 'wxPrintDialog::GetPrintDC'
        # make PrintDialog GC-safe
        spec.add_header_code <<~__HEREDOC
          static void wxRuby_delete_wxPrintDialog(void *self) 
          {
              wxPrintDialog *arg1 = (wxPrintDialog *)self;
              SWIG_RubyRemoveTracking(arg1);
              delete arg1;
          }

          static void GC_free_wxPrintDialog(void* object)
          {
            wxRuby_RegisterDeferredObjectDestroy(object, wxRuby_delete_wxPrintDialog);
          }
          __HEREDOC
        # wxPrintDialog is not actually a dialog, just a platform independent wrapper derived from wxObject,
        # so it is not caught by the generic wxWindow post-processor but still needs a deferred destroy as
        # destroying it will also destroy the wrapped actual dialog.
        spec.add_swig_code '%feature("freefunc") wxPrintDialog "GC_free_wxPrintDialog";'
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
