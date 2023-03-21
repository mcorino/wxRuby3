###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './event'

module WXRuby3

  class Director

    class AuiManagerEvent < Event

      def setup
        super
        spec.do_not_generate(:variables, :defines, :enums, :functions) # in AuiPaneInfo
      end
    end # class AuiManagerEvent

  end # class Director

end # module WXRuby3
