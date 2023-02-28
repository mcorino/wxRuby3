###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './ctrl_with_items'

module WXRuby3

  class Director

    class CheckListBox < ControlWithItems

      include Typemap::ArrayIntSelections

      def setup
        super
        setup_ctrl_with_items('wxCheckListBox')
        spec.override_inheritance_chain('wxCheckListBox',
                                        %w[wxListBox
                                           wxControlWithItems
                                           wxControl
                                           wxWindow
                                           wxEvtHandler
                                           wxObject])
        spec.ignore('wxCheckListBox::Create(wxWindow *,wxWindowID, const wxPoint &,const wxSize &,int,const wxString[],long,const wxValidator &,const wxString &)')
      end

    end # class ListBox

  end # class Director

end # module WXRuby3
