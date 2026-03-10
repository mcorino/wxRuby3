# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './event'

module WXRuby3

  class Director

    class WebViewEvent < Event

      def setup
        super
        # Windows-only IE emulation enum — not available on macOS/Linux
        spec.ignore 'wxWebViewIE_EmulationLevel'
        # Enums are already defined in WebView — suppress duplicates here
        spec.do_not_generate :variables, :defines, :functions, :enums
      end

    end # class WebViewEvent

  end # class Director

end # module WXRuby3
