###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class DerivedDC < Director

      def setup
        super
        spec.disable_proxies
        spec.gc_as_temporary spec.module_name
        if spec.module_name == 'wxScreenDC'
          spec.make_abstract 'wxScreenDC'
          # as a ScreenDC should always be a temporary stack object
          # we do not allow creation in Ruby but rather provide a class
          # method for block execution on a temp dc
          spec.add_extend_code 'wxScreenDC', <<~__HEREDOC
            static VALUE draw_on()
            {
              if (!wxRuby_IsAppRunning()) 
                rb_raise(rb_eRuntimeError, "A running Wx::App is required.");
              VALUE rc = Qnil;
              if (rb_block_given_p ())
              {
                wxScreenDC screen_dc;
                wxScreenDC* dc_ptr = &screen_dc;
                VALUE rb_dc = SWIG_NewPointerObj(SWIG_as_voidptr(dc_ptr), SWIGTYPE_p_wxScreenDC, 0);
                rc = rb_yield(rb_dc);
              }
              return rc;
            }
            __HEREDOC
          # not relevant anymore
          spec.ignore 'wxScreenDC::StartDrawingOnTop',
                      'wxScreenDC::EndDrawingOnTop',
                      'wxScreenDC::wxScreenDC'
        elsif spec.module_name == 'wxClientDC'
          spec.make_abstract 'wxClientDC'
          spec.ignore 'wxClientDC::wxClientDC'
          # as a ClientDC should best always be a temporary stack object
          # we do not allow creation in Ruby but rather provide a class
          # method for block execution on a temp dc
          spec.add_extend_code 'wxClientDC', <<~__HEREDOC
            static VALUE draw_on(wxWindow* win)
            {
              if (!wxRuby_IsAppRunning()) 
                rb_raise(rb_eRuntimeError, "A running Wx::App is required.");
              VALUE rc = Qnil;
              if (rb_block_given_p ())
              {
                wxClientDC client_dc(win);
                wxClientDC* dc_ptr = &client_dc;
                VALUE rb_dc = SWIG_NewPointerObj(SWIG_as_voidptr(dc_ptr), SWIGTYPE_p_wxClientDC, 0);
                rc = rb_yield(rb_dc);
              }
              return rc;
            }
          __HEREDOC
        elsif spec.module_name == 'wxPaintDC'
          spec.make_abstract 'wxPaintDC'
          spec.ignore 'wxPaintDC::wxPaintDC'
        elsif spec.module_name == 'wxMemoryDC'
          spec.items << 'wxBufferedDC' << 'wxBufferedPaintDC' << 'wxAutoBufferedPaintDC'
          spec.make_abstract 'wxMemoryDC'
          spec.make_abstract 'wxBufferedDC'
          spec.make_abstract 'wxBufferedPaintDC'
          spec.make_abstract 'wxAutoBufferedPaintDC'
          spec.ignore 'wxMemoryDC::wxMemoryDC',
                      'wxBufferedDC::wxBufferedDC',
                      'wxBufferedPaintDC::wxBufferedPaintDC',
                      'wxAutoBufferedPaintDC::wxAutoBufferedPaintDC'
          # like all DC's these should best always be a temporary stack objects
          # we do not allow creation in Ruby but rather provide a class
          # method for block execution on a temp dc
          spec.add_extend_code 'wxMemoryDC', <<~__HEREDOC
            static VALUE draw_on()
            {
              if (!wxRuby_IsAppRunning()) 
                rb_raise(rb_eRuntimeError, "A running Wx::App is required.");
              VALUE rc = Qnil;
              if (rb_block_given_p ())
              {
                wxMemoryDC mem_dc;
                wxMemoryDC* dc_ptr = &mem_dc;
                VALUE rb_dc = SWIG_NewPointerObj(SWIG_as_voidptr(dc_ptr), SWIGTYPE_p_wxMemoryDC, 0);
                rc = rb_yield(rb_dc);
              }
              return rc;
            }
            static VALUE draw_on(wxDC* tgt)
            {
              if (!wxRuby_IsAppRunning()) 
                rb_raise(rb_eRuntimeError, "A running Wx::App is required.");
              VALUE rc = Qnil;
              if (rb_block_given_p ())
              {
                wxMemoryDC mem_dc(tgt);
                wxMemoryDC* dc_ptr = &mem_dc;
                VALUE rb_dc = SWIG_NewPointerObj(SWIG_as_voidptr(dc_ptr), SWIGTYPE_p_wxMemoryDC, 0);
                rc = rb_yield(rb_dc);
              }
              return rc;
            }
            static VALUE draw_on(wxBitmap& tgt)
            {
              if (!wxRuby_IsAppRunning()) 
                rb_raise(rb_eRuntimeError, "A running Wx::App is required.");
              VALUE rc = Qnil;
              if (rb_block_given_p ())
              {
                wxMemoryDC mem_dc(tgt);
                wxMemoryDC* dc_ptr = &mem_dc;
                VALUE rb_dc = SWIG_NewPointerObj(SWIG_as_voidptr(dc_ptr), SWIGTYPE_p_wxMemoryDC, 0);
                rc = rb_yield(rb_dc);
              }
              return rc;
            }
          __HEREDOC
          spec.add_extend_code 'wxBufferedDC', <<~__HEREDOC
            static VALUE draw_on()
            {
              if (!wxRuby_IsAppRunning()) 
                rb_raise(rb_eRuntimeError, "A running Wx::App is required.");
              VALUE rc = Qnil;
              if (rb_block_given_p ())
              {
                wxBufferedDC dc;
                wxBufferedDC* dc_ptr = &dc;
                VALUE rb_dc = SWIG_NewPointerObj(SWIG_as_voidptr(dc_ptr), SWIGTYPE_p_wxBufferedDC, 0);
                rc = rb_yield(rb_dc);
              }
              return rc;
            }
            static VALUE draw_on(wxDC* tgt, const wxSize &area, int style=wxBUFFER_CLIENT_AREA)
            {
              if (!wxRuby_IsAppRunning()) 
                rb_raise(rb_eRuntimeError, "A running Wx::App is required.");
              VALUE rc = Qnil;
              if (rb_block_given_p ())
              {
                wxBufferedDC dc(tgt, area, style);
                wxBufferedDC* dc_ptr = &dc;
                VALUE rb_dc = SWIG_NewPointerObj(SWIG_as_voidptr(dc_ptr), SWIGTYPE_p_wxBufferedDC, 0);
                rc = rb_yield(rb_dc);
              }
              return rc;
            }
            static VALUE draw_on(wxDC* tgt, wxBitmap &buffer=wxNullBitmap, int style=wxBUFFER_CLIENT_AREA)
            {
              if (!wxRuby_IsAppRunning()) 
                rb_raise(rb_eRuntimeError, "A running Wx::App is required.");
              VALUE rc = Qnil;
              if (rb_block_given_p ())
              {
                wxBufferedDC dc(tgt, buffer, style);
                wxBufferedDC* dc_ptr = &dc;
                VALUE rb_dc = SWIG_NewPointerObj(SWIG_as_voidptr(dc_ptr), SWIGTYPE_p_wxBufferedDC, 0);
                rc = rb_yield(rb_dc);
              }
              return rc;
            }
          __HEREDOC
          spec.add_extend_code 'wxBufferedPaintDC', <<~__HEREDOC
            static VALUE draw_on(wxWindow* tgt, int style=wxBUFFER_CLIENT_AREA)
            {
              if (!wxRuby_IsAppRunning()) 
                rb_raise(rb_eRuntimeError, "A running Wx::App is required.");
              VALUE rc = Qnil;
              if (rb_block_given_p ())
              {
                wxBufferedPaintDC dc(tgt, style);
                wxBufferedPaintDC* dc_ptr = &dc;
                VALUE rb_dc = SWIG_NewPointerObj(SWIG_as_voidptr(dc_ptr), SWIGTYPE_p_wxBufferedPaintDC, 0);
                rc = rb_yield(rb_dc);
              }
              return rc;
            }
            static VALUE draw_on(wxWindow* tgt, wxBitmap &buffer=wxNullBitmap, int style=wxBUFFER_CLIENT_AREA)
            {
              if (!wxRuby_IsAppRunning()) 
                rb_raise(rb_eRuntimeError, "A running Wx::App is required.");
              VALUE rc = Qnil;
              if (rb_block_given_p ())
              {
                wxBufferedPaintDC dc(tgt, buffer, style);
                wxBufferedPaintDC* dc_ptr = &dc;
                VALUE rb_dc = SWIG_NewPointerObj(SWIG_as_voidptr(dc_ptr), SWIGTYPE_p_wxBufferedPaintDC, 0);
                rc = rb_yield(rb_dc);
              }
              return rc;
            }
          __HEREDOC
          spec.add_extend_code 'wxAutoBufferedPaintDC', <<~__HEREDOC
            static VALUE draw_on(wxWindow* tgt)
            {
              if (!wxRuby_IsAppRunning()) 
                rb_raise(rb_eRuntimeError, "A running Wx::App is required.");
              VALUE rc = Qnil;
              if (rb_block_given_p ())
              {
                wxAutoBufferedPaintDC dc(tgt);
                wxAutoBufferedPaintDC* dc_ptr = &dc;
                VALUE rb_dc = SWIG_NewPointerObj(SWIG_as_voidptr(dc_ptr), SWIGTYPE_p_wxAutoBufferedPaintDC, 0);
                rc = rb_yield(rb_dc);
              }
              return rc;
            }
          __HEREDOC
        elsif spec.module_name == 'wxMirrorDC'
          spec.make_abstract 'wxMirrorDC'
          spec.ignore 'wxMirrorDC::wxMirrorDC'
          # as a MirrorDC should best always be a temporary stack object
          # we do not allow creation in Ruby but rather provide a class
          # method for block execution on a temp dc
          spec.add_extend_code 'wxMirrorDC', <<~__HEREDOC
            static VALUE draw_on(wxDC* dc, bool mirror)
            {
              if (!wxRuby_IsAppRunning()) 
                rb_raise(rb_eRuntimeError, "A running Wx::App is required.");
              VALUE rc = Qnil;
              if (rb_block_given_p ())
              {
                wxMirrorDC dc(dc, mirror);
                wxMirrorDC* dc_ptr = &dc;
                VALUE rb_dc = SWIG_NewPointerObj(SWIG_as_voidptr(dc_ptr), SWIGTYPE_p_wxMirrorDC, 0);
                rc = rb_yield(rb_dc);
              }
              return rc;
            }
          __HEREDOC
        elsif spec.module_name == 'wxSVGFileDC'
          spec.items.concat %w[wxSVGBitmapHandler wxSVGBitmapFileHandler wxSVGBitmapEmbedHandler]
          spec.make_abstract 'wxSVGFileDC'
          spec.ignore 'wxSVGFileDC::wxSVGFileDC'
          # like all DC this should best always be a temporary stack object
          # we do not allow creation in Ruby but rather provide a class
          # method for block execution on a temp dc
          spec.add_extend_code 'wxSVGFileDC', <<~__HEREDOC
            static VALUE draw_on(const wxString &filename, int width=320, int height=240, double dpi=72, const wxString &title=wxString())
            {
              if (!wxRuby_IsAppRunning()) 
                rb_raise(rb_eRuntimeError, "A running Wx::App is required.");
              VALUE rc = Qnil;
              if (rb_block_given_p ())
              {
                wxSVGFileDC dc(filename, width, height, dpi, title);
                wxSVGFileDC* dc_ptr = &dc;
                VALUE rb_dc = SWIG_NewPointerObj(SWIG_as_voidptr(dc_ptr), SWIGTYPE_p_wxSVGFileDC, 0);
                rc = rb_yield(rb_dc);
              }
              return rc;
            }
          __HEREDOC
          spec.disown 'wxSVGBitmapHandler *handler'
          # all inherited from wxDC; only documented since they are not implemented for this DC class
          spec.ignore 'wxSVGFileDC::DestroyClippingRegion',
                      'wxSVGFileDC::CrossHair',
                      'wxSVGFileDC::FloodFill',
                      'wxSVGFileDC::GetPixel',
                      'wxSVGFileDC::SetPalette',
                      'wxSVGFileDC::GetDepth',
                      'wxSVGFileDC::SetLogicalFunction',
                      'wxSVGFileDC::GetLogicalFunction',
                      'wxSVGFileDC::StartDoc',
                      'wxSVGFileDC::EndDoc',
                      'wxSVGFileDC::StartPage',
                      'wxSVGFileDC::EndPage'
        elsif spec.module_name == 'wxGCDC'
          spec.make_abstract 'wxGCDC'
          spec.ignore 'wxGCDC::wxGCDC'
          # like all DC this should best always be a temporary stack object
          # we do not allow creation in Ruby but rather provide class
          # methods for block execution on a temp dc
          spec.add_extend_code 'wxGCDC', <<~__HEREDOC
            static VALUE draw_on(const wxWindowDC& dc)
            {
              if (!wxRuby_IsAppRunning()) 
                rb_raise(rb_eRuntimeError, "A running Wx::App is required.");
              VALUE rc = Qnil;
              if (rb_block_given_p ())
              {
                // Somehow there seems to be a problem with the Ruby GCDC value 
                // being GC-ed unless we block GC for the duration of the block
                // execution. Unclear why. We have similar code for other objects
                // where this issue does not come up.
                wxGCDC gc_dc(dc);
                wxGCDC* dc_ptr = &gc_dc;
                VALUE rb_dc = SWIG_NewPointerObj(SWIG_as_voidptr(dc_ptr), SWIGTYPE_p_wxGCDC, 0);
                rc = rb_yield(rb_dc);
              }
              return rc;
            }
            static VALUE draw_on(const wxMemoryDC& dc)
            {
              if (!wxRuby_IsAppRunning()) 
                rb_raise(rb_eRuntimeError, "A running Wx::App is required.");
              VALUE rc = Qnil;
              if (rb_block_given_p ())
              {
                // Somehow there seems to be a problem with the Ruby GCDC value 
                // being GC-ed unless we block GC for the duration of the block
                // execution. Unclear why. We have similar code for other objects
                // where this issue does not come up.
                wxGCDC gc_dc(dc);
                wxGCDC* dc_ptr = &gc_dc;
                VALUE rb_dc = SWIG_NewPointerObj(SWIG_as_voidptr(dc_ptr), SWIGTYPE_p_wxGCDC, 0);
                rc = rb_yield(rb_dc);
              }
              return rc;
            }
            static VALUE draw_on(const wxPrinterDC& dc)
            {
              if (!wxRuby_IsAppRunning()) 
                rb_raise(rb_eRuntimeError, "A running Wx::App is required.");
              VALUE rc = Qnil;
              if (rb_block_given_p ())
              {
                // Somehow there seems to be a problem with the Ruby GCDC value 
                // being GC-ed unless we block GC for the duration of the block
                // execution. Unclear why. We have similar code for other objects
                // where this issue does not come up.
                wxGCDC gc_dc(dc);
                wxGCDC* dc_ptr = &gc_dc;
                VALUE rb_dc = SWIG_NewPointerObj(SWIG_as_voidptr(dc_ptr), SWIGTYPE_p_wxGCDC, 0);
                rc = rb_yield(rb_dc);
              }
              return rc;
            }
            static VALUE draw_on(wxGraphicsContext* gc)
            {
              if (!wxRuby_IsAppRunning()) 
                rb_raise(rb_eRuntimeError, "A running Wx::App is required.");
              VALUE rc = Qnil;
              if (rb_block_given_p ())
              {
                // Somehow there seems to be a problem with the Ruby GCDC value 
                // being GC-ed unless we block GC for the duration of the block
                // execution. Unclear why. We have similar code for other objects
                // where this issue does not come up.
                wxGCDC gc_dc(gc);
                wxGCDC* dc_ptr = &gc_dc;
                VALUE rb_dc = SWIG_NewPointerObj(SWIG_as_voidptr(dc_ptr), SWIGTYPE_p_wxGCDC, 0);
                rc = rb_yield(rb_dc);
              }
              return rc;
            }
          __HEREDOC
          spec.ignore 'wxGCDC::wxGCDC(const wxEnhMetaFileDC &)'
        elsif spec.module_name == 'wxScaledDC'
          spec.items.clear # wxRuby extension; no XML docs
          spec.override_inheritance_chain('wxScaledDC', %w[wxDC wxObject])
          # as there are no dependencies parsed from XML make sure we're initialized after Wx::DC
          spec.initialize_at_end = true
          spec.no_proxy 'wxScaledDC'
          spec.include 'wxruby-ScaledDC.h'
          # wxScaledDc should ever only be used in a restricted scope
          # to be destructed directly after use therefor we make it abstract
          # and provide a class factory method #draw_on with accepts a block.
          # (as we there no classes defined in XML we cannot use add_extend_code
          #  so we use a workaround here)
          spec.add_swig_code <<~__HEREDOC
            %extend wxScaledDC {
            static VALUE draw_on(wxDC& target, double scale)
            {
              if (!wxRuby_IsAppRunning()) 
                rb_raise(rb_eRuntimeError, "A running Wx::App is required.");
              VALUE rc = Qnil;
              if (rb_block_given_p())
              {
                wxScaledDC scaled_dc(target, scale);
                wxScaledDC* p_scaled_dc = &scaled_dc;                        
                VALUE rb_scaled_dc = SWIG_NewPointerObj(SWIG_as_voidptr(p_scaled_dc), SWIGTYPE_p_wxScaledDC, 0);
                rc = rb_yield(rb_scaled_dc);
              }
              return rc;
            }
            };
            __HEREDOC
          spec.swig_import %w[ext/wxruby3/swig/classes/include/wxObject.h
                              ext/wxruby3/swig/classes/include/wxDC.h]
          spec.add_interface_code <<~__HEREDOC
            class wxScaledDC : public wxDC
            {
            public:
              virtual ~wxScaledDC() = 0;
            protected:
              wxScaledDC(wxDC& target, double scale);
            };
            __HEREDOC
        elsif spec.module_name == 'wxPrinterDC'
          spec.make_abstract 'wxPrinterDC'
          spec.ignore 'wxPrinterDC::wxPrinterDC'
          # as a PrinterDC should best always be a temporary stack object
          # we do not allow creation in Ruby but rather provide a class
          # method for block execution on a temp dc
          spec.add_extend_code 'wxPrinterDC', <<~__HEREDOC
            static VALUE draw_on(const wxPrintData &printData)
            {
              if (!wxRuby_IsAppRunning()) 
                rb_raise(rb_eRuntimeError, "A running Wx::App is required.");
              VALUE rc = Qnil;
              if (rb_block_given_p ())
              {
                wxPrinterDC dc(printData);
                wxPrinterDC* dc_ptr = &dc;
                VALUE rb_dc = SWIG_NewPointerObj(SWIG_as_voidptr(dc_ptr), SWIGTYPE_p_wxPrinterDC, 0);
                rc = rb_yield(rb_dc);
              }
              return rc;
            }
          __HEREDOC
        elsif spec.module_name == 'wxPostScriptDC'
          spec.make_abstract 'wxPostScriptDC'
          spec.ignore 'wxPostScriptDC::wxPostScriptDC'
          # as a PostScriptDC should best always be a temporary stack object
          # we do not allow creation in Ruby but rather provide a class
          # method for block execution on a temp dc
          spec.add_extend_code 'wxPostScriptDC', <<~__HEREDOC
            static VALUE draw_on(const wxPrintData &printData)
            {
              if (!wxRuby_IsAppRunning()) 
                rb_raise(rb_eRuntimeError, "A running Wx::App is required.");
              VALUE rc = Qnil;
              if (rb_block_given_p ())
              {
                wxPostScriptDC dc(printData);
                wxPostScriptDC* dc_ptr = &dc;
                VALUE rb_dc = SWIG_NewPointerObj(SWIG_as_voidptr(dc_ptr), SWIGTYPE_p_wxPostScriptDC, 0);
                rc = rb_yield(rb_dc);
              }
              return rc;
            }
          __HEREDOC
        else
          # ctors of all other derived DC require a running App
          spec.require_app spec.module_name
        end
      end
    end # class DerivedDC

  end # class Director

end # module WXRuby3
