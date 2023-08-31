###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './window'

module WXRuby3

  class Director

    class InfoBar < Window

      def setup
        super
        # no need to wrap this here as we do not proxy this
        spec.ignore 'wxInfoBar::SetFont'
      end
    end # class InfoBar

  end # class Director

end # module WXRuby3
