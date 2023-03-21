###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class Printer < Director

      def setup
        super
        spec.items << 'wxPrintout' << 'wxPrintPreview'
        spec.no_proxy 'wxPrinter', 'wxPrintPreview' # do not see the point in allowing overrides for the standard methods
        spec.new_object 'wxPrinter::CreateAbortWindow'
        spec.new_object 'wxPrinter::PrintDialog'
        # make wxPrinter GC-safe
        spec.ignore 'wxPrinter::GetPrintDialogData'
        spec.add_extend_code 'wxPrinter', <<~__HEREDOC
          wxPrintDialogData* GetPrintDialogData()
          { return new wxPrintDialogData(self->GetPrintDialogData()); }
          void SetPrintDialogData(const wxPrintDialogData& pd)
          { self->GetPrintDialogData() = pd; }
          __HEREDOC
        spec.new_object 'wxPrinter::GetPrintDialogData'
        spec.disown 'wxPrintout *' # Printout-s passed to PrintPreview will be managed by wxWidgets
        spec.add_header_code <<~__HEREDOC
          static void GC_mark_wxPrintPreview(void *ptr)
          {
            wxPrintPreview* print_preview = (wxPrintPreview*)ptr;
            wxPrintout* printout = print_preview->GetPrintout();
            rb_gc_mark( SWIG_RubyInstanceFor(printout) );
            wxPrintout* printout_for_printing = print_preview->GetPrintoutForPrinting();
            rb_gc_mark( SWIG_RubyInstanceFor(printout_for_printing) );
          }
          __HEREDOC
        spec.add_swig_code '%markfunc wxPrintPreview "GC_mark_wxPrintPreview";'
        # for GetCanvas
        spec.ignore('wxPrintPreview::GetCanvas', ignore_doc: false)
        spec.extend_interface('wxPrintPreview',
                              'virtual wxScrolledWindow* GetCanvas() const')
        # docs only mapping
        spec.map 'wxPreviewCanvas *' => 'wxScrolledWindow', swig: false do
          map_out
        end
        spec.suppress_warning(473,
                              'wxPrintPreview::GetCanvas',
                              'wxPrintPreview::GetFrame',
                              'wxPrintPreview::GetPrintout',
                              'wxPrintPreview::GetPrintoutForPrinting')
        # for various Printout getters
        spec.add_swig_code '%feature("new", "0") wxPrintout::GetDC;'
        spec.map_apply 'int * OUTPUT' => 'int *'
        spec.do_not_generate(:variables, :defines, :enums, :functions) # with PrintAbortDialog
      end
    end # class Printer

  end # class Director

end # module WXRuby3
