# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
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
