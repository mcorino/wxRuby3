# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './window'

module WXRuby3

  class Director

    class TipWindow < Window

      def setup
        super
        spec.disable_proxies
        spec.ignore 'wxTipWindow::SetTipWindowPtr'
        spec.ignore 'wxTipWindow::wxTipWindow'
        spec.add_extend_code 'wxTipWindow', <<~__HEREDOC
          wxTipWindow(wxWindow* parent, const wxString& text, wxCoord maxLength = 100)
          {
            return new wxTipWindow(parent, text, maxLength);
          }   
          __HEREDOC
      end

    end

  end

end
