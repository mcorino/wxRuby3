###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './event'

module WXRuby3

  class Director

    class CollapsiblePaneEvent < Event

      def setup
        super
        spec.do_not_generate :variables, :enums, :defines, :functions # with CollapsiblePane
      end
    end # class CollapsiblePaneEvent

  end # class Director

end # module WXRuby3
