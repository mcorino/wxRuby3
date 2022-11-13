#--------------------------------------------------------------------
# @file    graphics_object.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

module WXRuby3

  class Director

    class GraphicsObject < Director

      def setup
        super
        spec.items.concat %w[wxGraphicsPen wxGraphicsBrush wxGraphicsPath wxGraphicsFont wxGraphicsMatrix]
        spec.disable_proxies
        spec.ignore 'wxGraphicsObject::GetRenderer'
        spec.ignore 'wxGraphicsMatrix::Concat(const wxGraphicsMatrix &)'
        spec.ignore 'wxGraphicsMatrix::IsEqual(const wxGraphicsMatrix &)'
        spec.add_swig_code <<~__HEREDOC
          // Deal with GraphicsMatrix#get method
          %apply double *OUTPUT { wxDouble *a, wxDouble *b,
                                  wxDouble *c, wxDouble *d,
                                  wxDouble *tx , wxDouble *ty };
          __HEREDOC
      end
    end # class GraphicsObject

  end # class Director

end # module WXRuby3
