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
            static VALUE paint(VALUE proc)
            {
              VALUE rc = Qnil;
              if (rb_block_given_p ())
              {
                wxScreenDC screen_dc;
                wxDC* dc_ptr = &screen_dc;
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
        elsif spec.module_name == 'wxSVGFileDC'
          spec.items.concat %w[wxSVGBitmapHandler wxSVGBitmapFileHandler wxSVGBitmapEmbedHandler]
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
          # as a GCDC should always be a temporary stack object
          # we do not allow creation in Ruby but rather provide class
          # methods for block execution on a temp dc
          spec.add_extend_code 'wxGCDC', <<~__HEREDOC
            static VALUE draw_on(const wxWindowDC& dc)
            {
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
              wxScaledDC(wxDC& target, double scale);
              virtual ~wxScaledDC() = 0;
            };
            __HEREDOC
        else
          # ctors of all other derived DC require a running App
          spec.require_app spec.module_name
        end
      end
    end # class DerivedDC

  end # class Director

end # module WXRuby3
