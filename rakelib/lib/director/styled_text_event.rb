###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './event'

module WXRuby3

  class Director

    class StyledTextEvent < Event

      def setup
        super
        if Config.instance.wx_version >= '3.3.0'
          spec.ignore 'wxEVT_STC_KEY',
                      'wxEVT_STC_URIDROPPED'
        end
      end
    end # class StyledTextEvent

  end # class Director

end # module WXRuby3
