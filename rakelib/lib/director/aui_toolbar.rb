###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './window'

module WXRuby3

  class Director

    class AuiToolBar < Window

      def setup
        super
        spec.do_not_generate(:variables, :defines, :enums, :functions) # with AuiToolBarEvent
      end
    end # class AuiToolBar

  end # class Director

end # module WXRuby3
