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
        spec.map 'size_t, const wxPoint2DDouble *' => 'Array<Array<Float,Float>>' do
          map_in from: {type: 'Array<Array<Float,Float>>', index: 1},
                 temp: 'std::unique_ptr<wxPoint2DDouble[]> tmp_pts',
                 code: <<~__CODE
            bool ok = false;
            if (TYPE($input) == T_ARRAY)
            {
              ok = true;
              tmp_pts = std::make_unique<wxPoint2DDouble[]>(RARRAY_LEN($input));
              for (int i=0; i<RARRAY_LEN($input) ;++i)
              {
                VALUE el = rb_ary_entry($input, i);
                if (TYPE(el) == T_ARRAY && RARRAY_LEN(el) == 2)
                {
                  tmp_pts[i] = wxPoint2DDouble(NUM2DBL(rb_ary_entry(el, 0)), NUM2DBL(rb_ary_entry(el, 1)));
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
          map_typecheck precedence: 5, code: <<~__CODE
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
        spec.map 'size_t, const wxPoint2DDouble *, const wxPoint2DDouble *' do
          map_in from: {type: 'Array<Array<Array<Float,Float>,Array<Float,Float>>>', index: 0},
                 temp: ['std::unique_ptr<wxPoint2DDouble[]> tmp_begin', 'std::unique_ptr<wxPoint2DDouble[]> tmp_end'],
                 code: <<~__CODE
            bool ok = false;
            if (TYPE($input) == T_ARRAY)
            {
              ok = true;
              tmp_begin = std::make_unique<wxPoint2DDouble[]>(RARRAY_LEN($input));
              tmp_end = std::make_unique<wxPoint2DDouble[]>(RARRAY_LEN($input));
              for (int i=0; i<RARRAY_LEN($input) ;++i)
              {
                VALUE el = rb_ary_entry($input, i);
                if (TYPE(el) == T_ARRAY && RARRAY_LEN(el) == 2)
                {
                  VALUE begin_pt = rb_ary_entry(el, 0);
                  VALUE end_pt = rb_ary_entry(el, 1);
                  if (TYPE(begin_pt) == T_ARRAY && RARRAY_LEN(begin_pt) == 2 && TYPE(end_pt) == T_ARRAY && RARRAY_LEN(end_pt) == 2)
                  {
                    tmp_begin[i] = wxPoint2DDouble(NUM2DBL(rb_ary_entry(begin_pt, 0)), NUM2DBL(rb_ary_entry(begin_pt, 1)));
                    tmp_end[i] = wxPoint2DDouble(NUM2DBL(rb_ary_entry(end_pt, 0)), NUM2DBL(rb_ary_entry(end_pt, 1)));
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
          map_typecheck precedence: 10, code: <<~__CODE
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
        spec.new_object 'wxGraphicsContext::Create',
                        'wxGraphicsContext::CreateFromUnknownDC'
        # add convenience method providing efficient gc memory management
        spec.add_extend_code 'wxGraphicsContext', <<~__HEREDOC
          static VALUE draw_on(wxWindow* win)
          {
            VALUE rc = Qnil;
            if (rb_block_given_p())
            {
              wxGraphicsContext* p_gc = wxGraphicsContext::Create(win);
              VALUE rb_gc = SWIG_NewPointerObj(SWIG_as_voidptr(p_gc), SWIGTYPE_p_wxGraphicsContext, 1);
              rc = rb_yield(rb_gc);
              SWIG_RubyRemoveTracking((void *)p_gc);
              DATA_PTR(rb_gc) = NULL;
              delete p_gc;
            }
            return rc;
          }
          static VALUE draw_on(const wxWindowDC& dc)
          {
            VALUE rc = Qnil;
            if (rb_block_given_p())
            {
              wxGraphicsContext* p_gc = wxGraphicsContext::Create(dc);
              VALUE rb_gc = SWIG_NewPointerObj(SWIG_as_voidptr(p_gc), SWIGTYPE_p_wxGraphicsContext, 1);
              rc = rb_yield(rb_gc);
              SWIG_RubyRemoveTracking((void *)p_gc);
              DATA_PTR(rb_gc) = NULL;
              delete p_gc;
            }
            return rc;
          }
          static VALUE draw_on(const wxMemoryDC& dc)
          {
            VALUE rc = Qnil;
            if (rb_block_given_p())
            {
              wxGraphicsContext* p_gc = wxGraphicsContext::Create(dc);
              VALUE rb_gc = SWIG_NewPointerObj(SWIG_as_voidptr(p_gc), SWIGTYPE_p_wxGraphicsContext, 1);
              rc = rb_yield(rb_gc);
              SWIG_RubyRemoveTracking((void *)p_gc);
              DATA_PTR(rb_gc) = NULL;
              delete p_gc;
            }
            return rc;
          }
          static VALUE draw_on(const wxPrinterDC& dc)
          {
            VALUE rc = Qnil;
            if (rb_block_given_p())
            {
              wxGraphicsContext* p_gc = wxGraphicsContext::Create(dc);
              VALUE rb_gc = SWIG_NewPointerObj(SWIG_as_voidptr(p_gc), SWIGTYPE_p_wxGraphicsContext, 1);
              rc = rb_yield(rb_gc);
              SWIG_RubyRemoveTracking((void *)p_gc);
              DATA_PTR(rb_gc) = NULL;
              delete p_gc;
            }
            return rc;
          }
          static VALUE draw_on(wxImage& img)
          {
            VALUE rc = Qnil;
            if (rb_block_given_p())
            {
              wxGraphicsContext* p_gc = wxGraphicsContext::Create(img);
              VALUE rb_gc = SWIG_NewPointerObj(SWIG_as_voidptr(p_gc), SWIGTYPE_p_wxGraphicsContext, 1);
              rc = rb_yield(rb_gc);
              SWIG_RubyRemoveTracking((void *)p_gc);
              DATA_PTR(rb_gc) = NULL;
              delete p_gc;
            }
            return rc;
          }
          static VALUE draw_on()
          {
            VALUE rc = Qnil;
            if (rb_block_given_p())
            {
              wxGraphicsContext* p_gc = wxGraphicsContext::Create();
              VALUE rb_gc = SWIG_NewPointerObj(SWIG_as_voidptr(p_gc), SWIGTYPE_p_wxGraphicsContext, 1);
              rc = rb_yield(rb_gc);
              SWIG_RubyRemoveTracking((void *)p_gc);
              DATA_PTR(rb_gc) = NULL;
              delete p_gc;
            }
            return rc;
          }
          __HEREDOC
      end
    end # class GraphicsContext

  end # class Director

end # module WXRuby3
