###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './ctrl_with_items'

module WXRuby3

  class Director

    class Choice < ControlWithItems

      def setup
        super
        setup_ctrl_with_items('wxChoice')
        spec.override_inheritance_chain('wxChoice',
                                        %w[wxControlWithItems
                                           wxControl
                                           wxWindow
                                           wxEvtHandler
                                           wxObject])
        # redundant with good typemaps
        spec.ignore('wxChoice::wxChoice(wxWindow *,wxWindowID,const wxPoint &,const wxSize &,int,const wxString[],long,const wxValidator &,const wxString &)')
        spec.ignore('wxChoice::Create(wxWindow *,wxWindowID,const wxPoint &,const wxSize &,int,const wxString[],long,const wxValidator &,const wxString &)')
        spec.ignore('wxChoice::IsSorted') # provided by ControlWithItems
      end

    end # class Choice

  end # class Director

end # module WXRuby3
