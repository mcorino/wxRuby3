###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './window'

module WXRuby3

  class Director

    class RibbonToolBar < Window

      def setup
        super
        # exclude these; far better done in pure Ruby
        spec.ignore 'wxRibbonToolBar::SetToolClientData',
                    'wxRibbonToolBar::GetToolClientData', ignore_doc: false
        spec.map 'wxObject*' => 'Object', swig: false do
          map_in
          map_out
        end
        # not needed because of type mapping
        spec.ignore 'wxRibbonToolBar::GetToolId',
                    'wxRibbonToolBar::FindById'
        # map opaque wxRibbonToolBarToolBase* to the integer tool ID
        spec.map 'wxRibbonToolBarToolBase*' => 'Integer' do
          map_out code: '$result = ($1) ? INT2NUM((arg1)->GetToolId($1)) : Qnil;'
          map_directorout code: '$result = NIL_P($1) ? 0 : this->FindById(NUM2INT($1));'
          map_in code: '$1 = NIL_P($input) ? 0 : (arg1)->FindById(NUM2INT($input));'
          map_directorin code: '$input = ($1) ? INT2NUM(this->GetToolId($1)) : Qnil;'
          map_typecheck precedence: 'INTEGER', code: '$1 = (TYPE($input) == T_FIXNUM);'
        end
      end
    end # class RibbonToolBar

  end # class Director

end # module WXRuby3
