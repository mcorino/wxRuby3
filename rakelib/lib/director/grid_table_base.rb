# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class GridTableBase < Director

      include Typemap::GridCoords

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
            if (NIL_P($result))
            {
              // created by wxWidgets itself
              // convert and register
              $result = SWIG_NewPointerObj(SWIG_as_voidptr($1), SWIGTYPE_p_wxGridCellAttr, 0);
              wxRuby_RegisterGridCellAttr($1, $result);
            }
            __CODE
          map_directorin code: <<~__CODE
            $input = wxRuby_GridCellAttrInstance($1); // check for already registered instance
            if (NIL_P($input))
            {
              // created by wxWidgets itself
              // convert and register
              $input = SWIG_NewPointerObj(SWIG_as_voidptr($1), SWIGTYPE_p_wxGridCellAttr, 0);
              wxRuby_RegisterGridCellAttr($1, $input);
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
