# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './event'

module WXRuby3

  class Director

    class StyledTextEvent < Event

      def setup
        super
        if Config.instance.wx_version_check('3.3.0') >= 0
          spec.ignore 'wxEVT_STC_KEY',
                      'wxEVT_STC_URIDROPPED'
        end
      end
    end # class StyledTextEvent

  end # class Director

end # module WXRuby3
