###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './ctrl_with_items'

module WXRuby3

  class Director

    class BitmapComboBox < ControlWithItems

      def setup
        super
        setup_ctrl_with_items('wxBitmapComboBox')
        spec.override_inheritance_chain('wxBitmapComboBox',
                                        %w[wxComboBox
                                           wxControlWithItems
                                           wxControl
                                           wxWindow
                                           wxEvtHandler
                                           wxObject])
        spec.ignore 'wxBitmapComboBox::Insert(const wxString &, const wxBitmap &, unsigned int, wxClientData *)',
                    'wxBitmapComboBox::Append(const wxString &, const wxBitmap &, wxClientData *)'
      end

    end # class BitmapComboBox

  end # class Director

end # module WXRuby3
