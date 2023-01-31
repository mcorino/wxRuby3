###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './event_handler'

module WXRuby3

  class Director

    class NumericPropertyValidator < EvtHandler

      def setup
        super
        spec.no_proxy 'wxNumericPropertyValidator::Clone'
        spec.do_not_generate :variables, :defines, :enums, :functions
      end

    end # class NumericPropertyValidator

  end # class Director

end # module WXRuby3
