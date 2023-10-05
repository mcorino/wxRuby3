# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './window'

module WXRuby3

  class Director

    class StaticBox < Window

      def setup
        super
        if Config.instance.wx_port == :wxqt || Config.platform == :macosx
          # missing from implementation currently
          spec.ignore 'wxStaticBox::wxStaticBox(wxWindow *, wxWindowID, wxWindow *, const wxPoint &, const wxSize &, long, const wxString &)',
                      'wxStaticBox::Create(wxWindow *, wxWindowID, wxWindow *, const wxPoint &, const wxSize &, long, const wxString &)'
        end
      end
    end # class StaticBox

  end # class Director

end # module WXRuby3
