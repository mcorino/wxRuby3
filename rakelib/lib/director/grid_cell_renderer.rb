# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class GridCellRenderer < Director

      def setup
        super
        spec.gc_as_marked # tailored tracking
        # use custom free func to be able to account for more complex inheritance
        spec.add_header_code 'extern void GC_free_GridCellRenderer(void *ptr);'
        spec.add_swig_code '%feature("freefunc") wxGridCellRenderer "GC_free_GridCellRenderer";'
        if spec.module_name == 'wxGridCellRenderer'
          # exposing the mixin wxClientDataContainer/wxSharedClientDataContainer has no real upside
          # for wxRuby; far easier to just use member variables in derived classes
          spec.override_inheritance_chain('wxGridCellRenderer', [])
          spec.regard('wxGridCellRenderer::~wxGridCellRenderer')
          # add method for correctly wrapping PGEditor output references
          spec.add_header_code <<~__CODE
            extern VALUE mWxGRID; // declare external module reference
            extern VALUE wxRuby_GridCellRendererInstance(wxGridCellRenderer* wx_rnd);
            extern void wxRuby_RegisterGridCellRenderer(wxGridCellRenderer* wx_rnd, VALUE rb_rnd);
            extern VALUE wxRuby_WrapWxGridCellRendererInRuby(const wxGridCellRenderer *wx_gcr)
            {
              // If no object was passed to be wrapped.
              if ( ! wx_gcr )
                return Qnil;

              // check for registered instance
              VALUE rb_gcr = wxRuby_GridCellRendererInstance(const_cast<wxGridCellRenderer*> (wx_gcr));
              if (rb_gcr && !NIL_P(rb_gcr))
              {
                return rb_gcr;
              }

              // unregistered renderer must be a standard C++ class renderer
              const void *ptr = 0;
              wxString class_name;
              if ((ptr = dynamic_cast<const wxGridCellBoolRenderer*> (wx_gcr)))
              {
                class_name = "GridCellBoolRenderer";
              }
              else if ((ptr = dynamic_cast<const wxGridCellFloatRenderer*> (wx_gcr)))
              {
                class_name = "GridCellFloatRenderer";
              }
              else if ((ptr = dynamic_cast<const wxGridCellAutoWrapStringRenderer*> (wx_gcr)))
              {
                class_name = "GridCellAutoWrapStringRenderer";
              }
              else if ((ptr = dynamic_cast<const wxGridCellDateTimeRenderer*> (wx_gcr)))
              {
                class_name = "GridCellDateTimeRenderer";
              }
              else if ((ptr = dynamic_cast<const wxGridCellDateRenderer*> (wx_gcr)))
              {
                class_name = "GridCellDateRenderer";
              }
              else if ((ptr = dynamic_cast<const wxGridCellEnumRenderer*> (wx_gcr)))
              {
                class_name = "GridCellEnumRenderer";
              }
              else if ((ptr = dynamic_cast<const wxGridCellNumberRenderer*> (wx_gcr)))
              {
                class_name = "GridCellNumberRenderer";
              }
              else if ((ptr = dynamic_cast<const wxGridCellStringRenderer*> (wx_gcr)))
              {
                class_name = "GridCellStringRenderer";
              }
              VALUE r_class = Qnil;
              if ( ptr && class_name.Len() > 0 )
              {
                wxCharBuffer wx_classname = class_name.mb_str();
                VALUE r_class_name = rb_intern(wx_classname.data ()); // wxRuby class name (minus 'wx')
                if (rb_const_defined(mWxGRID, r_class_name))
                  r_class = rb_const_get(mWxGRID, r_class_name);
              }

              // If we cannot find the class output a warning and return nil
              if ( r_class == Qnil )
              {
                rb_warn("Error wrapping object; class `%s' is not (yet) supported in wxRuby",
                        (const char *)class_name.mb_str() );
                return Qnil;
              }

              // Otherwise, retrieve the swig type info for this class and wrap it
              // in Ruby. Make it owned to manage the ref count if GC claims the object.
              // wxRuby_GetSwigTypeForClass is defined in wx.i
              swig_type_info* swig_type = wxRuby_GetSwigTypeForClass(r_class);
              rb_gcr = SWIG_NewPointerObj(const_cast<void*> (ptr), swig_type, 0);
              wxRuby_RegisterGridCellRenderer(const_cast<wxGridCellRenderer*> (wx_gcr), rb_gcr);
              return rb_gcr;
            }

            extern void GC_free_GridCellRenderer(void *ptr)
            {
              wxGridCellRenderer* gc_rdr = (wxGridCellRenderer*)ptr; 
              if (ptr)
                gc_rdr->DecRef();
            }
            __CODE
        else
          case spec.module_name
          when 'wxGridCellStringRenderer'
            spec.override_inheritance_chain('wxGridCellStringRenderer', %w[wxGridCellRenderer])
          when 'wxGridCellDateTimeRenderer'
            spec.override_inheritance_chain('wxGridCellDateTimeRenderer', %w[wxGridCellDateRenderer wxGridCellStringRenderer wxGridCellRenderer])
          else
            spec.override_inheritance_chain(spec.module_name, %w[wxGridCellStringRenderer wxGridCellRenderer])
          end
          # due to the flawed wxWidgets XML docs we need to explicitly add these here
          # otherwise the derived renderers won't be allocatable due to pure virtuals
          spec.extend_interface spec.module_name,
              'virtual wxGridCellRenderer* Clone() const',
              'virtual void Draw(wxGrid &grid, wxGridCellAttr &attr, wxDC &dc, const wxRect &rect, int row, int col, bool isSelected)',
              'virtual wxSize GetBestSize(wxGrid &grid, wxGridCellAttr &attr, wxDC &dc, int row, int col)'
          spec.force_proxy spec.module_name
        end
        unless spec.module_name == 'wxGridCellRenderer'
          # type mapping for Clone return ref
          spec.map 'wxGridCellRenderer*' => 'Wx::GRID::GridCellRenderer' do
            add_header_code 'extern VALUE wxRuby_WrapWxGridCellRendererInRuby(const wxGridCellRenderer *wx_gcr);'
            map_out code: '$result = wxRuby_WrapWxGridCellRendererInRuby($1);'
          end
        end
        # handled; can be suppressed
        spec.suppress_warning(473, "#{spec.module_name}::Clone")
      end
    end # class GridCellRenderer

  end # class Director

end # module WXRuby3
