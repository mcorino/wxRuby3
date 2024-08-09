# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class DerivedDC < Director

      def setup
        super
        spec.disable_proxies
        spec.gc_as_untracked spec.module_name
        case spec.module_name
        when 'wxScreenDC'
          spec.override_inheritance_chain('wxScreenDC', ['wxDC', { 'wxReadOnlyDC' => 'wxDC' }, 'wxObject']) if Config.instance.wx_version >= '3.3.0'
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
        when 'wxClientDC'
          spec.override_inheritance_chain('wxClientDC', ['wxWindowDC', 'wxDC', { 'wxReadOnlyDC' => 'wxDC' }, 'wxObject']) if Config.instance.wx_version >= '3.3.0'
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
        when 'wxPaintDC'
          spec.override_inheritance_chain('wxPaintDC', ['wxClientDC', 'wxWindowDC' 'wxDC', { 'wxReadOnlyDC' => 'wxDC' }, 'wxObject']) if Config.instance.wx_version >= '3.3.0'
          spec.make_abstract 'wxPaintDC'
          spec.ignore 'wxPaintDC::wxPaintDC'
          spec.add_header_code <<~__HEREDOC
            // we need this static method here because we do not want SWIG to parse the preprocessor 
            // statements (#if/#else/#endif) which it does in %extend blocks
            #include "wx/dcbuffer.h"
            static VALUE do_check_native_double_buffer()
            {
            #if wxALWAYS_NATIVE_DOUBLE_BUFFER
              return Qtrue;
            #else
              return Qfalse;
            #endif
            }
            __HEREDOC
          spec.add_extend_code 'wxPaintDC', <<~__HEREDOC
            #include "wx/dcbuffer.h"
            static VALUE has_native_double_buffer()
            {
              return do_check_native_double_buffer();
            }  
            __HEREDOC
        when 'wxMemoryDC'
          spec.items << 'wxBufferedDC' << 'wxBufferedPaintDC'
          spec.override_inheritance_chain('wxMemoryDC', ['wxDC', { 'wxReadOnlyDC' => 'wxDC' }, 'wxObject']) if Config.instance.wx_version >= '3.3.0'
          spec.gc_as_untracked %w[wxBufferedDC wxBufferedPaintDC]
          spec.override_inheritance_chain('wxBufferedDC', ['wxMemoryDC', 'wxDC', { 'wxReadOnlyDC' => 'wxDC' }, 'wxObject']) if Config.instance.wx_version >= '3.3.0'
          spec.override_inheritance_chain('wxBufferedPaintDC', ['wxBufferedDC', 'wxMemoryDC', 'wxDC', { 'wxReadOnlyDC' => 'wxDC' }, 'wxObject']) if Config.instance.wx_version >= '3.3.0'
          spec.make_abstract 'wxMemoryDC'
          spec.make_abstract 'wxBufferedDC'
          spec.make_abstract 'wxBufferedPaintDC'
          spec.ignore 'wxMemoryDC::wxMemoryDC',
                      'wxBufferedDC::wxBufferedDC',
                      'wxBufferedPaintDC::wxBufferedPaintDC'
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
            static VALUE draw_on(wxWindow* tgt, wxBitmap &buffer, int style=wxBUFFER_CLIENT_AREA)
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
        when 'wxMirrorDC'
          spec.override_inheritance_chain('wxMirrorDC', ['wxDC', { 'wxReadOnlyDC' => 'wxDC' }, 'wxObject']) if Config.instance.wx_version >= '3.3.0'
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
        when 'wxSVGFileDC'
          spec.override_inheritance_chain('wxSVGFileDC', ['wxDC', { 'wxReadOnlyDC' => 'wxDC' }, 'wxObject']) if Config.instance.wx_version >= '3.3.0'
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
        when 'wxGCDC'
          spec.override_inheritance_chain('wxGCDC', ['wxDC', { 'wxReadOnlyDC' => 'wxDC' }, 'wxObject']) if Config.instance.wx_version >= '3.3.0'
          spec.make_abstract 'wxGCDC'
          spec.ignore 'wxGCDC::wxGCDC'
          # like all DC this should best always be a temporary stack object
          # we do not allow creation in Ruby but rather provide class
          # methods for block execution on a temp dc
          if Config.instance.features_set?('USE_PRINTING_ARCHITECTURE', Director.AnyOf(*%w[WXMSW WXOSX USE_GTKPRINT]))
            spec.add_extend_code 'wxGCDC', <<~__HEREDOC
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
              __HEREDOC
          end
          spec.add_extend_code 'wxGCDC', <<~__HEREDOC
            static VALUE draw_on()
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
                wxGCDC gc_dc;
                wxGCDC* dc_ptr = &gc_dc;
                VALUE rb_dc = SWIG_NewPointerObj(SWIG_as_voidptr(dc_ptr), SWIGTYPE_p_wxGCDC, 0);
                rc = rb_yield(rb_dc);
              }
              return rc;
            }
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
          spec.disown 'wxGraphicsContext *gc'
          spec.ignore 'wxGCDC::wxGCDC(const wxEnhMetaFileDC &)'
        when 'wxScaledDC'
          spec.items.clear # wxRuby extension; no XML docs
          if Config.instance.wx_version >= '3.3.0'
            spec.override_inheritance_chain('wxScaledDC', ['wxDC', { 'wxReadOnlyDC' => 'wxDC' }, 'wxObject'])
          else
            spec.override_inheritance_chain('wxScaledDC', %w[wxDC wxObject])
          end
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
        when 'wxPrinterDC'
          spec.override_inheritance_chain('wxPrinterDC', ['wxDC', { 'wxReadOnlyDC' => 'wxDC' }, 'wxObject']) if Config.instance.wx_version >= '3.3.0'
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
        when 'wxPostScriptDC'
          spec.override_inheritance_chain('wxPostScriptDC', ['wxDC', { 'wxReadOnlyDC' => 'wxDC' }, 'wxObject']) if Config.instance.wx_version >= '3.3.0'
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
        when 'wxDCOverlay'
          spec.items << 'wxOverlay'
          spec.make_abstract 'wxDCOverlay'
          spec.ignore 'wxDCOverlay::wxDCOverlay'
          spec.add_extend_code 'wxDCOverlay', <<~__HEREDOC
            static VALUE draw_on(wxOverlay &overlay, wxDC *dc)
            {
              if (!wxRuby_IsAppRunning()) 
                rb_raise(rb_eRuntimeError, "A running Wx::App is required.");
              VALUE rc = Qnil;
              if (rb_block_given_p ())
              {
                wxDCOverlay ovl_dc(overlay, dc);
                wxDCOverlay* ovl_dc_ptr = &ovl_dc;
                VALUE rb_dc = SWIG_NewPointerObj(SWIG_as_voidptr(ovl_dc_ptr), SWIGTYPE_p_wxDCOverlay, 0);
                rc = rb_yield(rb_dc);
              }
              return rc;
            }
            static VALUE draw_on(wxOverlay &overlay, wxDC *dc, int x, int y, int width, int height)
            {
              if (!wxRuby_IsAppRunning()) 
                rb_raise(rb_eRuntimeError, "A running Wx::App is required.");
              VALUE rc = Qnil;
              if (rb_block_given_p ())
              {
                wxDCOverlay ovl_dc(overlay, dc, x, y, width, height);
                wxDCOverlay* ovl_dc_ptr = &ovl_dc;
                VALUE rb_dc = SWIG_NewPointerObj(SWIG_as_voidptr(ovl_dc_ptr), SWIGTYPE_p_wxDCOverlay, 0);
                rc = rb_yield(rb_dc);
              }
              return rc;
            }
            __HEREDOC
          if Config.instance.wx_version >= '3.3.0'
            spec.items << 'wxOverlayDC'
            spec.override_inheritance_chain('wxOverlayDC', ['wxDC', { 'wxReadOnlyDC' => 'wxDC' }, 'wxObject'])
            spec.make_abstract 'wxOverlayDC'
            spec.ignore 'wxOverlayDC::wxOverlayDC'
            spec.add_extend_code 'wxOverlayDC', <<~__HEREDOC
            static VALUE draw_on(wxOverlay &overlay, wxWindow *win)
            {
              if (!wxRuby_IsAppRunning()) 
                rb_raise(rb_eRuntimeError, "A running Wx::App is required.");
              VALUE rc = Qnil;
              if (rb_block_given_p ())
              {
                wxOverlayDC ovl_dc(overlay, win);
                wxOverlayDC* ovl_dc_ptr = &ovl_dc;
                VALUE rb_dc = SWIG_NewPointerObj(SWIG_as_voidptr(ovl_dc_ptr), SWIGTYPE_p_wxOverlayDC, 0);
                rc = rb_yield(rb_dc);
              }
              return rc;
            }
            static VALUE draw_on(wxOverlay &overlay, wxWindow *dc, const wxRect &rect)
            {
              if (!wxRuby_IsAppRunning()) 
                rb_raise(rb_eRuntimeError, "A running Wx::App is required.");
              VALUE rc = Qnil;
              if (rb_block_given_p ())
              {
                wxOverlayDC ovl_dc(overlay, win, rect);
                wxOverlayDC* ovl_dc_ptr = &ovl_dc;
                VALUE rb_dc = SWIG_NewPointerObj(SWIG_as_voidptr(ovl_dc_ptr), SWIGTYPE_p_wxOverlayDC, 0);
                rc = rb_yield(rb_dc);
              }
              return rc;
            }
            __HEREDOC
          end
        else
          spec.override_inheritance_chain(spec.module_name, ['wxDC', { 'wxReadOnlyDC' => 'wxDC' }, 'wxObject']) if Config.instance.wx_version >= '3.3.0'
          # ctors of all other derived DC require a running App
          spec.require_app spec.module_name
        end
      end
    end # class DerivedDC

  end # class Director

end # module WXRuby3
