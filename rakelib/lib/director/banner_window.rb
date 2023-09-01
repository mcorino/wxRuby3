###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './window'

module WXRuby3

  class Director

    class BannerWindow < Window

      def setup
        super
        # not useful in wxRuby with keyword arg support
        spec.ignore 'wxBannerWindow::wxBannerWindow(wxWindow*,wxDirection)'
      end
    end # class BannerWindow

  end # class Director

end # module WXRuby3
