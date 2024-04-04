# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class AffineMatrix2D < Director

      def setup
        spec.items.unshift('wxAffineMatrix2DBase') << 'wxMatrix2D'

        spec.make_abstract 'wxAffineMatrix2DBase'
        spec.disable_proxies

        spec.map_apply 'int * OUTPUT' => ['wxDouble *']
        spec.map 'wxPoint2DDouble *' => 'Wx::Point2DDouble' do
          map_in ignore: true, temp: 'wxPoint2DDouble tmp', code: '$1 = &tmp;'

          map_argout code: <<~__CODE
            $result = SWIG_Ruby_AppendOutput($result, SWIG_NewPointerObj(new wxPoint2DDouble(tmp$argnum), SWIGTYPE_p_wxPoint2DDouble, SWIG_POINTER_OWN));
            __CODE
        end
        spec.map 'wxMatrix2D *' => 'Wx::Matrix2D' do
          map_in ignore: true, temp: 'wxMatrix2D tmp', code: '$1 = &tmp;'

          map_argout code: <<~__CODE
            $result = SWIG_Ruby_AppendOutput($result, SWIG_NewPointerObj(new wxMatrix2D(tmp$argnum), SWIGTYPE_p_wxPoint2DDouble, SWIG_POINTER_OWN));
            __CODE
        end

        spec.ignore 'wxAffineMatrix2D::Mirror',
                    'wxAffineMatrix2D::TransformPoint',
                    'wxAffineMatrix2D::TransformDistance',
                    'wxAffineMatrix2D::IsEqual'

        spec.regard 'wxMatrix2D::m_11', 'wxMatrix2D::m_12',
                    'wxMatrix2D::m_21', 'wxMatrix2D::m_22'

      end

    end

  end

end
