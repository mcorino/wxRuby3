# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './button'

module WXRuby3

  class Director

    class ContextHelpButton < Button

      def setup
        super
        spec.items << 'wxContextHelp'
        spec.no_proxy 'wxContextHelp'
      end
    end # class ContextHelpButton

  end # class Director

end # module WXRuby3
