###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './event'

module WXRuby3

  class Director

    class HyperlinkEvent < Event

      def setup
        super
        spec.do_not_generate :variables, :enums, :defines, :functions # with HyperlinkCtrl
      end
    end # class HyperlinkEvent

  end # class Director

end # module WXRuby3
