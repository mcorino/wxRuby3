###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './ctrl_with_items'

module WXRuby3

  class Director

    class ListBox < ControlWithItems

      include Typemap::ArrayIntSelections

      def setup
        super
        setup_ctrl_with_items('wxListBox')
        spec.override_inheritance_chain('wxListBox',
                                        %w[wxControlWithItems
                                           wxControl
                                           wxWindow
                                           wxEvtHandler
                                           wxObject])
        spec.ignore('wxListBox::InsertItems(unsigned int,const wxString *,unsigned int)')
        spec.ignore('wxListBox::IsSorted') # provided by ControlWithItems
      end

    end # class ListBox

  end # class Director

end # module WXRuby3
