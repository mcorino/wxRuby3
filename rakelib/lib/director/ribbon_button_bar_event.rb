# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './event'

module WXRuby3

  class Director

    class RibbonButtonBarEvent < Event

      def setup
        super
        # map opaque wxRibbonButtonBarButtonBase* to the integer tool ID
        spec.map 'wxRibbonButtonBarButtonBase*' => 'Integer' do
          map_out code: '$result = (($1) && (arg1)->GetBar()) ? INT2NUM((arg1)->GetBar()->GetItemId($1)) : Qnil;'
          map_in code: <<~__CODE
            if ((arg1)->GetBar() == 0) rb_raise(rb_eRuntimeError, "Cannot set button before bar has been set.");
            $1 = NIL_P($input) ? 0 : (arg1)->GetBar()->GetItemById(NUM2INT($input));
            __CODE
          map_typecheck precedence: 'INTEGER', code: '$1 = (TYPE($input) == T_FIXNUM);'
        end
        # customize ctor
        spec.ignore 'wxRibbonButtonBarEvent::wxRibbonButtonBarEvent', ignore_doc: false
        spec.add_extend_code 'wxRibbonButtonBarEvent', <<~__CODE
          wxRibbonButtonBarEvent(wxEventType command_type=wxEVT_NULL, int win_id=0, wxRibbonButtonBar *bar=NULL, VALUE button_id=Qnil)
          {
            wxRibbonButtonBarButtonBase* button = (!NIL_P(button_id) && bar) ? bar->GetItemById(NUM2INT(button_id)) : 0;
            return new wxRibbonButtonBarEvent(command_type, win_id, bar, button); 
          }
          __CODE
        spec.do_not_generate :variables, :enums, :defines, :functions
      end
    end # class RibbonButtonBarEvent

  end # class Director

end # module WXRuby3
