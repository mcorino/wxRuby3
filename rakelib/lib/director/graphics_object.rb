# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class GraphicsObject < Director

      def setup
        super
        spec.items.concat %w[wxGraphicsPen wxGraphicsBrush wxGraphicsPath wxGraphicsFont wxGraphicsMatrix wxGraphicsBitmap wxGraphicsRenderer]
        spec.disable_proxies
        spec.ignore 'wxGraphicsMatrix::Concat(const wxGraphicsMatrix &)'
        spec.ignore 'wxGraphicsMatrix::IsEqual(const wxGraphicsMatrix &)'
        spec.ignore 'wxGraphicsMatrix::GetNativeMatrix'
        spec.ignore 'wxGraphicsBitmap::GetNativeBitmap'
        spec.ignore 'wxGraphicsPath::GetNativePath',
                    'wxGraphicsPath::UnGetNativePath'
        spec.ignore 'wxGraphicsRenderer::CreateContextFromNativeHDC',
                    'wxGraphicsRenderer::CreateBitmapFromNativeBitmap',
                    'wxGraphicsRenderer::CreateContextFromNativeContext',
                    'wxGraphicsRenderer::CreateContextFromNativeWindow',
                    'wxGraphicsRenderer::CreateContext(const wxEnhMetaFileDC&)'
        unless Config.instance.features_set?('USE_CAIRO')
          spec.ignore 'wxGraphicsRenderer::GetCairoRenderer'
        end
        unless Config.instance.features_set?('WXMSW')
          spec.ignore 'wxGraphicsRenderer::GetGDIPlusRenderer',
                      'wxGraphicsRenderer::GetDirect2DRenderer'
        end
        spec.new_object 'wxGraphicsRenderer::CreateContext'
        # Deal with GraphicsMatrix#get method
        spec.map_apply 'double *OUTPUT' => [ 'wxDouble *a', 'wxDouble *b',
                                             'wxDouble *c', 'wxDouble *d',
                                             'wxDouble *tx' , 'wxDouble *ty' ]
        spec.ignore 'wxGraphicsPath::GetBox(wxDouble *, wxDouble *, wxDouble *, wxDouble *) const',
                    'wxGraphicsPath::GetCurrentPoint(wxDouble*,wxDouble*) const'
        # wxGraphicsRenderer::GetVersion
        spec.map_apply 'int * OUTPUT' => ['int *major', 'int *minor', 'int *micro']
        if Config.platform == :mingw
          # it seems for WXMSW there is a problem cleaning up GraphicsObjects in GC after
          # the wxApp has ended (probably because some other wxWidgets cleanup already
          # forcibly deleted their resources)
          spec.add_header_code <<~__HEREDOC
            // special free func is needed to clean up only as long the app still runs
            // the rest we leave for the system clean up as the process terminates
            void GC_free_GraphicsObject(wxGraphicsObject *go) 
            {
              SWIG_RubyRemoveTracking(go);
              if ( wxRuby_IsAppRunning() )
                delete go;
            }
          __HEREDOC
          spec.add_swig_code '%feature("freefunc") wxGraphicsPen "GC_free_GraphicsObject";'
          spec.add_swig_code '%feature("freefunc") wxGraphicsBrush "GC_free_GraphicsObject";'
          spec.add_swig_code '%feature("freefunc") wxGraphicsPath "GC_free_GraphicsObject";'
          spec.add_swig_code '%feature("freefunc") wxGraphicsFont "GC_free_GraphicsObject";'
          spec.add_swig_code '%feature("freefunc") wxGraphicsMatrix "GC_free_GraphicsObject";'
          spec.add_swig_code '%feature("freefunc") wxGraphicsBitmap "GC_free_GraphicsObject";'
        end
      end
    end # class GraphicsObject

  end # class Director

end # module WXRuby3
