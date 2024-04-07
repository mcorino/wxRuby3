# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class GraphicsContext < Director

      def setup
        super
        spec.items << 'wxGraphicsGradientStop' << 'wxGraphicsGradientStops' << 'wxGraphicsPenInfo'
        spec.disable_proxies
        # do not track GraphicContext objects as that causes problems probably for similar
        # reasons as for DC objects
        spec.gc_as_untracked
        # doc error
        spec.ignore 'wxGraphicsGradientStop::wxGraphicsGradientStop'
        spec.extend_interface 'wxGraphicsGradientStop',
                              'wxGraphicsGradientStop(wxColour col=wxTransparentColour, float pos=0.0)'
        # ignore all these; wxRuby only supports the ::draw_on methods
        spec.ignore 'wxGraphicsContext::CreateFromNative',
                    'wxGraphicsContext::CreateFromNativeWindow',
                    'wxGraphicsContext::CreateFromNativeHDC',
                    'wxGraphicsContext::CreateFromUnknownDC',
                    'wxGraphicsContext::GetNativeContext',
                    'wxGraphicsContext::Create(const wxEnhMetaFileDC &)',
                    'wxGraphicsContext::CreateMatrix(const wxAffineMatrix2DBase &) const',
                    'wxGraphicsContext::DrawLines(size_t, const wxPoint2DDouble *, wxPolygonFillMode)',
                    'wxGraphicsContext::StrokeLines(size_t, const wxPoint2DDouble *)',
                    'wxGraphicsContext::StrokeLines (size_t, const wxPoint2DDouble *, const wxPoint2DDouble *)'
        spec.ignore_unless(Config::AnyOf.new('WXMSW', 'WXOSX', 'USE_GTKPRINT'), 'wxGraphicsContext::Create(const wxPrinterDC &)')
        spec.new_object 'wxGraphicsContext::Create'
        spec.add_header_code <<~__HEREDOC
          // special free funcs are needed to clean up Dashes array if it has been
          // set; wxWidgets does not do this automatically so will leak if not
          // dealt with.
          void GC_free_wxGraphicsPenInfo(wxGraphicsPenInfo *pen_info) 
          {
            SWIG_RubyRemoveTracking(pen_info);
            if (pen_info)
            {
              wxDash *dashes;
              int dash_count = pen_info->GetDashes(&dashes);
              if ( dash_count )
                delete dashes;
            }
            delete pen_info;
          }
          __HEREDOC
        # dealt with below - these require special handling because of the use
        # of wxDash array, which cannot be freed until the peninfo is disposed of
        # or until a new dash pattern is specified.
        spec.ignore(%w[wxGraphicsPenInfo::GetDashes wxGraphicsPenInfo::Dashes], ignore_doc: false)
        spec.ignore 'wxGraphicsPenInfo::GetDash'
        spec.add_extend_code 'wxGraphicsPenInfo', <<~__HEREDOC
          // Returns a ruby array with the dash lengths
          VALUE get_dashes() 
          {
            VALUE rb_dashes = rb_ary_new();
            wxDash* dashes;
            int dash_count = $self->GetDashes(&dashes);
            for ( int i = 0; i < dash_count; i++ )
            {
              rb_ary_push(rb_dashes, INT2NUM(dashes[i]));
            }
            return rb_dashes;
          }
        
          // Sets the dashes to have the lengths defined in the ruby array of ints
          void dashes(VALUE rb_dashes) 
          {
            // Check right parameter type
            if ( TYPE(rb_dashes) != T_ARRAY )
              rb_raise(rb_eTypeError, 
                       "Wrong argument type for set_dashes, should be Array");
        
            // Get old value in case it needs to be deallocated to avoid leaking
            wxDash* old_dashes;
            int old_dashes_count = $self->GetDashes(&old_dashes);
        
            // Create a C++ wxDash array to hold the new dashes, and populate
            int new_dash_count = RARRAY_LEN(rb_dashes);
            wxDash* new_dashes = new wxDash[ new_dash_count ];
            for ( int i = 0; i < new_dash_count; i++ )
            {
              new_dashes[i] = NUM2INT(rb_ary_entry(rb_dashes, i));
            }
            $self->Dashes(new_dash_count, new_dashes);
        
            // Clean up the old if it existed
            if ( old_dashes_count )
              delete old_dashes;
          }
          __HEREDOC
        # type mappings
        # Typemap to fix GraphicsContext#get_text_extent and get_dpi and get_clip_box
        spec.map_apply 'double *OUTPUT' => [ 'wxDouble* width', 'wxDouble* height',
                                             'wxDouble* descent', 'wxDouble* externalLeading',
                                             'wxDouble *dpiX', 'wxDouble *dpiY',
                                             'wxDouble *x', 'wxDouble *y', 'wxDouble *w', 'wxDouble *h']
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
        # for GetPartialTextExtents
        spec.map 'wxArrayDouble &widths' => 'Array<Float>' do
          map_in ignore: true, temp: 'wxArrayDouble tmp', code: '$1 = &tmp;'

          map_argout code: <<~__CODE
            $result = rb_ary_new();
            for (size_t i = 0; i < $1->GetCount(); i++)
            {
              rb_ary_push($result,DBL2NUM( $1->Item(i) ) );
            }
            __CODE
        end
        # add convenience method providing efficient gc memory management
        if Config.instance.features_set?('USE_PRINTING_ARCHITECTURE', Director.AnyOf(*%w[WXMSW WXOSX USE_GTKPRINT]))
          spec.add_extend_code 'wxGraphicsContext', <<~__HEREDOC
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
            __HEREDOC
        end
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
