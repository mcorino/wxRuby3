###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class GraphicsContext < Director

      def setup
        super
        spec.disable_proxies
        # these static creators require a running app
        spec.require_app 'wxGraphicsContext::Create',
                         'wxGraphicsContext::CreateFromUnknownDC'
        spec.ignore 'wxGraphicsContext::CreateFromNative',
                    'wxGraphicsContext::CreateFromNativeWindow',
                    'wxGraphicsContext::CreateFromNativeHDC',
                    'wxGraphicsContext::GetNativeContext',
                    'wxGraphicsContext::Create(const wxEnhMetaFileDC &)'
        # type mappings
        # Typemap to fix GraphicsContext#get_text_extent
        spec.map_apply 'double *OUTPUT' => [ 'wxDouble* width', 'wxDouble* height',
                                             'wxDouble* descent', 'wxDouble* externalLeading' ]
        spec.map 'wxDouble* width, wxDouble* height, wxDouble* descent, wxDouble* externalLeading' do
          map_directorargout code: <<~__CODE
            if ( (TYPE(result) == T_ARRAY) && (RARRAY_LEN(result) >= 2) )
            {
              *$1 = ($*1_ltype)NUM2INT(rb_ary_entry(result,0));
              *$2 = ($*2_ltype)NUM2INT(rb_ary_entry(result,1));
              if ( ($3 != NULL ) && RARRAY_LEN(result) >= 3)
                *$3 = ($*3_ltype)NUM2INT(rb_ary_entry(result,2));
              if ( ( $4 != NULL ) && RARRAY_LEN(result) >= 4 )
                *$4 = ($*4_ltype)NUM2INT(rb_ary_entry(result,3));
            }
            __CODE
        end
        spec.map 'size_t n, const wxPoint2DDouble *beginPoints, const wxPoint2DDouble *endPoints' do
          map_in from: {type: 'Array<Array<Array<Float,Float>,Array<Float,Float>>>', index: 0},
                 temp: ['std::unique_ptr<wxPoint2DDouble> tmp_begin', 'std::unique_ptr<wxPoint2DDouble> tmp_end'],
                 code: <<~__CODE
            bool ok = false;
            if (TYPE($input) == T_ARRAY)
            {
              ok = true;
              tmp_begin.reset(new wxPoint2DDouble[RARRAY_LEN($input)]);
              tmp_end.reset(new wxPoint2DDouble[RARRAY_LEN($input)]);
              for (int i=0; i<RARRAY_LEN($input) ;++i)
              {
                VALUE el = rb_ary_entry($input, i);
                if (TYPE(el) == T_ARRAY && RARRAY_LEN(el) == 2)
                {
                  VALUE begin_pt = rb_ary_entry(el, 0);
                  VALUE end_pt = rb_ary_entry(el, 1);
                  if (TYPE(begin_pt) == T_ARRAY && RARRAY_LEN(begin_pt) == 2 && TYPE(end_pt) == T_ARRAY && RARRAY_LEN(end_pt) == 2)
                  {
                    tmp_begin.get()[i] = wxPoint2DDouble(NUM2DBL(rb_ary_entry(begin_pt, 0)), NUM2DBL(rb_ary_entry(begin_pt, 1)));
                    tmp_end.get()[i] = wxPoint2DDouble(NUM2DBL(rb_ary_entry(end_pt, 0)), NUM2DBL(rb_ary_entry(end_pt, 1)));
                  }
                  else
                  { ok = false; }
                }
                else
                { ok = false; }
              }
              if (ok)
              {
                $1 = RARRAY_LEN($input);
                $2 = tmp_begin.get();
                $3 = tmp_end.get();
              }
            }
            if (!ok)
            {
              rb_raise(rb_eArgError, "Invalid value for %i", $argnum-1);
            }
            __CODE
          map_default code: '$1 = 0; $2 = NULL; $3 = NULL;'
          map_typecheck code: <<~__CODE
            $1 = false; 
            if (TYPE($input) == T_ARRAY && RARRAY_LEN($input)>0)
            {
              VALUE el = rb_ary_entry($input, 0);
              if (TYPE(el) == T_ARRAY && RARRAY_LEN(el) == 2)
              {
                VALUE pt = rb_ary_entry(el, 0);
                $1 = TYPE(pt) == T_ARRAY;
              }
            }
            __CODE
        end
        spec.map 'size_t n, const wxPoint2DDouble *points' => 'Array<Array<Float,Float>>' do
          map_in from: {type: 'Array<Array<Float,Float>>', index: 1},
                 temp: 'std::unique_ptr<wxPoint2DDouble> tmp_pts',
                 code: <<~__CODE
            bool ok = false;
            if (TYPE($input) == T_ARRAY)
            {
              ok = true;
              tmp_pts.reset(new wxPoint2DDouble[RARRAY_LEN($input)]);
              for (int i=0; i<RARRAY_LEN($input) ;++i)
              {
                VALUE el = rb_ary_entry($input, i);
                if (TYPE(el) == T_ARRAY && RARRAY_LEN(el) == 2)
                {
                  tmp_pts.get()[i] = wxPoint2DDouble(NUM2DBL(rb_ary_entry(el, 0)), NUM2DBL(rb_ary_entry(el, 1)));
                }
                else
                { ok = false; }
              }
              if (ok)
              {
                $1 = RARRAY_LEN($input);
                $2 = tmp_pts.get();
              }
            }
            if (!ok)
            {
              rb_raise(rb_eArgError, "Invalid value for %i", $argnum-1);
            }
          __CODE
          map_default code: '$1 = 0; $2 = NULL;'
          map_typecheck code: <<~__CODE
            $1 = false; 
            if (TYPE($input) == T_ARRAY && RARRAY_LEN($input)>0)
            {
              VALUE el = rb_ary_entry($input, 0);
              if (TYPE(el) == T_ARRAY && RARRAY_LEN(el) == 2)
              {
                VALUE pt = rb_ary_entry(el, 0);
                $1 = TYPE(pt) != T_ARRAY;
              }
            }
          __CODE
        end
      end
    end # class GraphicsContext

  end # class Director

end # module WXRuby3
