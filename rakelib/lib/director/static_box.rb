###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './window'

module WXRuby3

  class Director

    class StaticBox < Window

      def setup
        super
        if Config.instance.wx_port == :wxQT || Config.platform == :macosx
          # missing from implementation currently
          spec.ignore 'wxStaticBox::wxStaticBox(wxWindow *, wxWindowID, wxWindow *, const wxPoint &, const wxSize &, long, const wxString &)',
                      'wxStaticBox::Create(wxWindow *, wxWindowID, wxWindow *, const wxPoint &, const wxSize &, long, const wxString &)'
        end
      end
    end # class StaticBox

  end # class Director

end # module WXRuby3
