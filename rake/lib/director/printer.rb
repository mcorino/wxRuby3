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
        # this map does nothing for the implementation since we changed the declaration above
        # but it will update the docs
        spec.map 'wxPreviewCanvas *' => 'wxScrolledWindow' do
          map_out code: ''
        end
        spec.suppress_warning(473,
                              'wxPrintPreview::GetCanvas',
                              'wxPrintPreview::GetFrame',
                              'wxPrintPreview::GetPrintout',
                              'wxPrintPreview::GetPrintoutForPrinting')
        # for various Printout getters
        spec.map_apply 'int *' => 'int * OUTPUT'
      end
    end # class Printer

  end # class Director

end # module WXRuby3
