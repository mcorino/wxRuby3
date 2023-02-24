###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './window'

module WXRuby3

  class Director

    class RibbonButtonBar < Window

      def setup
        super
        # exclude these; far better done in pure Ruby
        spec.ignore 'wxRibbonButtonBar::SetItemClientData',
                    'wxRibbonButtonBar::GetItemClientData',
                    'wxRibbonButtonBar::SetItemClientObject',
                    'wxRibbonButtonBar::GetItemClientObject'
        # not needed because of type mapping
        spec.ignore 'wxRibbonButtonBar::GetItemId',
                    'wxRibbonButtonBar::GetItemById'
        # map opaque wxRibbonButtonBarButtonBase* to the integer tool ID
        spec.map 'wxRibbonButtonBarButtonBase*' => 'Integer' do
          map_out code: '$result = ($1) ? INT2NUM((arg1)->GetItemId($1)) : Qnil;'
          map_directorout code: '$result = NIL_P($1) ? 0 : this->GetItemById(NUM2INT($1));'
          map_in code: '$1 = NIL_P($input) ? 0 : (arg1)->GetItemById(NUM2INT($input));'
          map_directorin code: '$input = ($1) ? INT2NUM(this->GetItemId($1)) : Qnil;'
          map_typecheck precedence: 'INTEGER', code: '$1 = (TYPE($input) == T_FIXNUM);'
        end
      end
    end # class RibbonButtonBar

  end # class Director

end # module WXRuby3
