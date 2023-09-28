# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
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
