# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class SharedEvtHandler < Director

      def setup
        super
        spec.items.clear
        spec.add_header_code <<~__HEREDOC
          #include "wxruby-SharedEventHandler.h"
          __HEREDOC
        spec.add_init_code <<~__HEREDOC
          wx_setup_WxRubySharedEvtHandler(mWxRT);
          __HEREDOC
      end

    end

  end

end
