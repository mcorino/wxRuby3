#--------------------------------------------------------------------
# @file    listbox.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

require_relative './ctrl_with_items'

module WXRuby3

  class Director

    class ListBox < ControlWithItems

      def setup
        super
        setup_ctrl_with_items('wxListBox')
        spec.ignore_bases('wxListBox' => %w[wxItemContainer])
        spec.override_base('wxListBox', 'wxControlWithItems')
        spec.ignore('wxListBox::InsertItems(unsigned int,const wxString *,unsigned int)')
        spec.swig_include('../shared/arrayint_selections.i')
      end

    end # class ListBox

  end # class Director

end # module WXRuby3
