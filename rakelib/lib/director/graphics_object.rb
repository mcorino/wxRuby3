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
        # Deal with GraphicsMatrix#transform_point and #transform_distance methods
        spec.ignore 'wxGraphicsMatrix::TransformPoint', 'wxGraphicsMatrix::TransformDistance'
        spec.map_apply 'double *INOUT' => [ 'wxDouble *x' , 'wxDouble *y',
                                            'wxDouble *dx', 'wxDouble *dy']
        spec.add_extend_code 'wxGraphicsMatrix', <<~__CODE
          wxPoint2DDouble transform_point(wxDouble x, wxDouble y)
          {
            $self->TransformPoint(&x, &y);
            return wxPoint2DDouble(x, y);
          }
          wxPoint2DDouble transform_point(const wxPoint2DDouble& pt)
          {
            wxDouble x = pt.m_x, y = pt.m_y;
            $self->TransformPoint(&x, &y);
            return wxPoint2DDouble(x, y);
          }
          wxPoint2DDouble transform_distance(wxDouble dx, wxDouble dy)
          {
            $self->TransformDistance(&dx, &dy);
            return wxPoint2DDouble(dx, dy);
          }
          wxPoint2DDouble transform_distance(const wxPoint2DDouble& p)
          {
            wxDouble dx = p.m_x, dy = p.m_y;
            $self->TransformDistance(&dx, &dy);
            return wxPoint2DDouble(dx, dy);
          }
          __CODE
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
