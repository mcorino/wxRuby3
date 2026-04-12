# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx

  module WEB

    class WebView < Wx::Control

      # Sets emulation level.
      #
      # This function is useful to change the emulation level of the system browser control used for {Wx::WebView}
      # implementation under MSW, rather than using the currently default, IE11-compatible, level (with wxRuby3).
      #
      # Please notice that this function works by modifying the per-user part of MSW registry, which has several
      # implications: first, it is sufficient to call it only once (per user) as the changes done by it are persistent
      # and, second, if you do not want them to be persistent, you need to call it with {Wx::WEB::WEBVIEWIE_EMU_DEFAULT}
      # argument explicitly.
      #
      # In particular, this function should be called to allow {Wx::WEB::WebView#run_script} to work for JavaScript code
      # returning arbitrary objects, which is not supported at the default emulation level.
      #
      # If set to a level higher than installed version, the highest available level will be used instead.
      # {Wx::WEB::WEBVIEWIE_EMU_IE11} is recommended for best performance and experience.
      #
      # This function is MSW-specific and doesn't exist under other platforms.
      #
      # @param [Wx::WEB::WebViewIE_EmulationLevel] level
      # @return [Boolean] true on success, false on failure (a warning message is also logged in the latter case).
      # @wxrb_require WXMSW
      def self.msw_set_ie_emulation_level(level=Wx::WEB::WEBVIEWIE_EMU_IE11); end
    end

  end

end
