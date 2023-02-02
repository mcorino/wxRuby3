###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class GridCellRenderer < Director

      def setup
        super
        spec.gc_as_refcounted
        if spec.module_name == 'wxGridCellRenderer'
          if Config.instance.wx_version >= '3.1.7'
            spec.items << 'wxSharedClientDataContainer'
            spec.fold_bases('wxGridCellRenderer' => ['wxSharedClientDataContainer'])
          else
            spec.items << 'wxClientDataContainer'
            spec.fold_bases('wxGridCellRenderer' => ['wxClientDataContainer'])
          end
          spec.override_inheritance_chain('wxGridCellRenderer', [])
          spec.regard('wxGridCellRenderer::~wxGridCellRenderer')
          # add method for correctly wrapping PGEditor output references
          spec.add_header_code <<~__CODE
            extern VALUE mWxGrids; // declare external module reference
            extern VALUE wxRuby_WrapWxGridCellRendererInRuby(const wxGridCellRenderer *wx_gcr, int own = 0)
            {
              // If no object was passed to be wrapped.
              if ( ! wx_gcr )
                return Qnil;

              const void *ptr = 0;
              wxString class_name;
              if ((ptr = dynamic_cast<const wxGridCellBoolRenderer*> (wx_gcr)))
              {
                class_name = "GridCellBoolRenderer";
              }
              else if ((ptr = dynamic_cast<const wxGridCellStringRenderer*> (wx_gcr)))
              {
                class_name = "GridCellStringRenderer";
              }
              else if ((ptr = dynamic_cast<const wxGridCellFloatRenderer*> (wx_gcr)))
              {
                class_name = "GridCellFloatRenderer";
              }
              else if ((ptr = dynamic_cast<const wxGridCellAutoWrapStringRenderer*> (wx_gcr)))
              {
                class_name = "GridCellAutoWrapStringRenderer";
              }
              else if ((ptr = dynamic_cast<const wxGridCellDateRenderer*> (wx_gcr)))
              {
                class_name = "GridCellDateRenderer";
              }
              else if ((ptr = dynamic_cast<const wxGridCellDateTimeRenderer*> (wx_gcr)))
              {
                class_name = "GridCellDateTimeRenderer";
              }
              else if ((ptr = dynamic_cast<const wxGridCellEnumRenderer*> (wx_gcr)))
              {
                class_name = "GridCellEnumRenderer";
              }
              else if ((ptr = dynamic_cast<const wxGridCellNumberRenderer*> (wx_gcr)))
              {
                class_name = "GridCellNumberRenderer";
              }
              VALUE r_class = Qnil;
              if ( ptr && class_name.Len() > 2 )
              {
                wxCharBuffer wx_classname = class_name.mb_str();
                VALUE r_class_name = rb_intern(wx_classname.data () + 2); // wxRuby class name (minus 'wx')
                if (rb_const_defined(mWxGrids, r_class_name))
                  r_class = rb_const_get(mWxGrids, r_class_name);
              }

              // If we cannot find the class output a warning and return nil
              if ( r_class == Qnil )
              {
                rb_warn("Error wrapping object; class `%s' is not (yet) supported in wxRuby",
                        (const char *)class_name.mb_str() );
                return Qnil;
              }

              // Otherwise, retrieve the swig type info for this class and wrap it
              // in Ruby. wxRuby_GetSwigTypeForClass is defined in wx.i
              swig_type_info* swig_type = wxRuby_GetSwigTypeForClass(r_class);
              VALUE r_gcr = SWIG_NewPointerObj(const_cast<void*> (ptr), swig_type, own);
              return r_gcr;
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
        # these require wxRuby to take ownership (ref counted)
        spec.new_object "#{spec.module_name}::Clone"
        unless spec.module_name == 'wxGridCellRenderer'
          # type mapping for Clone return ref => claim ownership
          spec.map 'wxGridCellRenderer*' => 'Wx::Grids::GridCellRenderer' do
            add_header_code 'extern VALUE wxRuby_WrapWxGridCellRendererInRuby(const wxGridCellRenderer *wx_gcr, int own = 0);'
            map_out code: '$result = wxRuby_WrapWxGridCellRendererInRuby($1, 1);'
          end
        end
        # handled; can be suppressed
        spec.suppress_warning(473, "#{spec.module_name}::Clone")
      end
    end # class GridCellRenderer

  end # class Director

end # module WXRuby3
