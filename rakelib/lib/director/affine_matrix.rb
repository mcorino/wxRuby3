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
        spec.ignore 'wxAffineMatrix2DBase::TransformPoint(wxDouble*, wxDouble*)',
                    'wxAffineMatrix2DBase::TransformDistance(wxDouble*, wxDouble*)'

        spec.map 'wxPoint2DDouble&' => 'Array(Float, Float), Wx::Point2DDouble' do
          add_header_code '#include <memory>'
          map_in temp: 'std::unique_ptr<$1_basetype> tmp', code: <<~__CODE
            if ( TYPE($input) == T_DATA )
            {
              void* argp$argnum;
              SWIG_ConvertPtr($input, &argp$argnum, $1_descriptor, 0);
              $1 = reinterpret_cast< $1_basetype * >(argp$argnum);
            }
            else if ( TYPE($input) == T_ARRAY )
            {
              $1 = new $1_basetype( NUM2DBL( rb_ary_entry($input, 0) ),
                                    NUM2DBL( rb_ary_entry($input, 1) ) );
              tmp.reset($1); // auto destruct when method scope ends 
            }
            else
            {
              rb_raise(rb_eTypeError, "Wrong type for $1_basetype parameter");
            }
            __CODE
          map_typecheck precedence: 'POINTER', code: <<~__CODE
            void *vptr = 0;
            $1 = 0;
            if (TYPE($input) == T_ARRAY && RARRAY_LEN($input) == 2)
              $1 = 1;
            else if (TYPE($input) == T_DATA && SWIG_CheckState (SWIG_ConvertPtr ($input, &vptr, $1_descriptor, 0)))
              $1 = 1;
            __CODE
        end

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
