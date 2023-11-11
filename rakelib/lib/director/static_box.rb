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
        # missing from implementation currently for WXOSX (and WXQT)
        spec.ignore_unless(Config::AnyOf.new(*%w[WXMSW WXGTK]),
                           'wxStaticBox::wxStaticBox(wxWindow *, wxWindowID, wxWindow *, const wxPoint &, const wxSize &, long, const wxString &)',
                           'wxStaticBox::Create(wxWindow *, wxWindowID, wxWindow *, const wxPoint &, const wxSize &, long, const wxString &)')
      end
    end # class StaticBox

  end # class Director

end # module WXRuby3
