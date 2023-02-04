###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class GridTableBase < Director

      def setup
        super
        spec.ignore %w[
          wxGridTableBase::CanHaveAttributes
          wxGridTableBase::GetAttrProvider
          wxGridTableBase::SetAttrProvider
          wxGridTableBase::GetAttrPtr
          wxGridTableBase::GetValueAsCustom
          wxGridTableBase::SetValueAsCustom]
        spec.map 'wxGridCellAttr::wxAttrKind' do
          map_directorin code: '$input = INT2NUM($1);'
        end
        # wxWidgets takes over managing the ref count
        spec.disown('wxGridCellAttr* attr')
        # handle registering mapping
        spec.map 'wxGridCellAttr *' => 'Wx::GRID::GridCellAttr' do
          add_header_code 'extern void wxRuby_RegisterGridCellAttr(wxGridCellAttr* wx_attr, VALUE rb_attr);',
                          'extern VALUE wxRuby_GridCellAttrInstance(wxGridCellAttr* wx_attr);'
          map_out code: <<~__CODE
            $result = wxRuby_GridCellAttrInstance($1); // check for already registered instance
            if ($result && !NIL_P($result))
            {
              $1->DecRef();
            }
            else
            {
              // created by wxWidgets itself; no registration necessary (yet)
              // make owned instance which will take care of the refcount when GC claimed
              $result = SWIG_NewPointerObj(SWIG_as_voidptr($1), SWIGTYPE_p_wxGridCellAttr, 1);
            }
            __CODE
          map_directorin code: <<~__CODE
            $input = wxRuby_GridCellAttrInstance($1); // check for already registered instance
            if ($input && !NIL_P($input))
            {
              $1->DecRef();
            }
            else
            {
              // newly created somewhere; no registration necessary (yet)
              // make owned instance which will take care of the refcount when GC claimed
              $input = SWIG_NewPointerObj(SWIG_as_voidptr($1), SWIGTYPE_p_wxGridCellAttr, 1);
            }
            __CODE
          map_check code: 'wxRuby_RegisterGridCellAttr($1, argv[$argnum-2]);'
        end
        # this requires wxRuby to take ownership (ref counted)
        spec.new_object 'wxGridTableBase::GetAttr'
        # these warnings are handled and can be suppressed
        spec.suppress_warning(473,
                              'wxGridTableBase::GetAttr',
                              'wxGridTableBase::GetView')
      end
    end # class GridTableBase

  end # class Director

end # module WXRuby3
