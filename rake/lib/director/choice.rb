#--------------------------------------------------------------------
# @file    choice.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

require_relative './ctrl_with_items'

module WXRuby3

  class Director

    class Choice < CtrlWithItems

      def setup
        super
        setup_ctrl_with_items('wxChoice')
        spec.ignore_bases('wxChoice' => %w[wxItemContainer])
        spec.override_base('wxChoice', 'wxControlWithItems')
        # redundant with good typemaps
        spec.ignore('wxChoice::wxChoice(wxWindow *,wxWindowID,const wxPoint &,const wxSize &,int,const wxString[],long,const wxValidator &,const wxString &)')
        spec.ignore('wxChoice::Create(wxWindow *,wxWindowID,const wxPoint &,const wxSize &,int,const wxString[],long,const wxValidator &,const wxString &)')
      end

    end # class Choice

  end # class Director

end # module WXRuby3
