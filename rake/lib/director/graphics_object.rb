###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class GraphicsObject < Director

      def setup
        super
        spec.items.concat %w[wxGraphicsPen wxGraphicsBrush wxGraphicsPath wxGraphicsFont wxGraphicsMatrix wxGraphicsBitmap]
        spec.disable_proxies
        spec.ignore 'wxGraphicsObject::GetRenderer'
        spec.ignore 'wxGraphicsMatrix::Concat(const wxGraphicsMatrix &)'
        spec.ignore 'wxGraphicsMatrix::IsEqual(const wxGraphicsMatrix &)'
        spec.ignore 'wxGraphicsBitmap::GetNativeBitmap'
        # Deal with GraphicsMatrix#get method
        spec.map_apply 'double *OUTPUT' => [ 'wxDouble *a', 'wxDouble *b',
                                             'wxDouble *c', 'wxDouble *d',
                                             'wxDouble *tx' , 'wxDouble *ty' ]
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
              if ( rb_gv_get("__wx_app_ended__" ) != Qtrue )
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
