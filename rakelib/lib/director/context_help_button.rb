###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
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
