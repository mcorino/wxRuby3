# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './window'

module WXRuby3

  class Director

    class Button < Window

      def setup
        spec.no_proxy %w[wxButton::SetDefault]
        super
      end
    end # class Button

  end # class Director

end # module WXRuby3
