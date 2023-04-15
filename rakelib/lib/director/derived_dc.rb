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
        if spec.module_name == 'wxScreenDC'
          spec.make_abstract 'wxScreenDC'
          # as a ScreenDC should always be a temporary stack object
          # we do not allow creation in Ruby but rather provide a class
          # method for block execution on a temp dc
          spec.add_extend_code 'wxScreenDC', <<~__HEREDOC
            static VALUE paint(VALUE proc)
            {
              if (rb_block_given_p ())
              {
                wxScreenDC screen_dc;
                wxDC* dc_ptr = &screen_dc;
                VALUE rb_dc = SWIG_NewPointerObj(SWIG_as_voidptr(dc_ptr), SWIGTYPE_p_wxScreenDC, 0);
                return rb_yield(rb_dc);
              }
              return Qnil;
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
          spec.ignore 'wxGCDC::wxGCDC(const wxEnhMetaFileDC &)'
        else
          # ctors of all other derived DC require a running App
          spec.require_app spec.module_name
        end
      end
    end # class DerivedDC

  end # class Director

end # module WXRuby3
