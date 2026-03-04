# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class Printer < Director

      include Typemap::PrintPageRange

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
          WXRUBY_TRACE_GUARD(WxRubyTraceGCMarkPrintPreview, "GC_MARK_PRINT_PREVIEW")

          // forward decl
          SWIGINTERN void free_wxPrintPreview(void *self); 

          // this is the actual print preview marker which is called for Ruby owned instances from the
          // Ruby standard marker and by the container preview frame for disowned instances 
          void WxRuby_mark_wxPrintPreview(void* ptr)
          {   
            WXRUBY_TRACE_IF(WxRubyTraceGCMarkPrintPreview, 2)
              WXRUBY_TRACE("> WxRuby_mark_wxPrintPreview : " << ptr)
            WXRUBY_TRACE_END

            if (ptr)
            {
              wxPrintPreview* print_preview = (wxPrintPreview*)ptr;
              wxPrintout* printout = print_preview->GetPrintout();
              VALUE rb_prtout = SWIG_RubyInstanceFor(printout);
 
              WXRUBY_TRACE_IF(WxRubyTraceGCMarkPrintPreview, 3)
                WXRUBY_TRACE("| WxRuby_mark_wxPrintPreview : marking preview printout " << printout << " -> " << rb_prtout);
              WXRUBY_TRACE_END

              rb_gc_mark(rb_prtout);

              printout = print_preview->GetPrintoutForPrinting();
              rb_prtout = SWIG_RubyInstanceFor(printout); 

              WXRUBY_TRACE_IF(WxRubyTraceGCMarkPrintPreview, 3)
                WXRUBY_TRACE("| WxRuby_mark_wxPrintPreview : marking printing printout " << printout << " -> " << rb_prtout);
              WXRUBY_TRACE_END

              rb_gc_mark(rb_prtout);
            }

            WXRUBY_TRACE_IF(WxRubyTraceGCMarkPrintPreview, 2)
              WXRUBY_TRACE("< WxRuby_mark_wxPrintPreview : " << ptr)
            WXRUBY_TRACE_END
          }

          // this is the Ruby standard marker called by the Ruby GC mark phase
          // for Ruby instances visible to Ruby
          static void GC_mark_wxPrintPreview(void *ptr)
          {
            WXRUBY_TRACE_IF(WxRubyTraceGCMarkPrintPreview, 2)
              WXRUBY_TRACE("> GC_mark_wxPrintPreview : " << ptr)
            WXRUBY_TRACE_END

            VALUE rb_pp = SWIG_RubyInstanceFor(ptr);
            // if this is still an instance 'owned' by Ruby
            if (!RB_NIL_P(rb_pp) && RDATA(rb_pp)->dfree==free_wxPrintPreview)
            {
              WxRuby_mark_wxPrintPreview(ptr);
            } 
            else
            {
              WXRUBY_TRACE_IF(WxRubyTraceGCMarkPrintPreview, 3)
                WXRUBY_TRACE("| GC_mark_wxPrintPreview : skip marking disowned instance")
              WXRUBY_TRACE_END
            } 

            WXRUBY_TRACE_IF(WxRubyTraceGCMarkPrintPreview, 2)
              WXRUBY_TRACE("< GC_mark_wxPrintPreview : " << ptr)
            WXRUBY_TRACE_END
          }
          __HEREDOC
        spec.add_swig_code '%markfunc wxPrintPreview "GC_mark_wxPrintPreview";'
        # as we do not support derived previews there is no need to support these
        spec.ignore 'wxPrintPreview::SetCanvas', 'wxPrintPreview::PaintPage'
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
