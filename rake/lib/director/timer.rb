###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './event_handler'

module WXRuby3

  class Director

    class Timer < EvtHandler

      def setup
        super
        spec.do_not_generate(:variables, :enums, :defines, :functions)
      end
    end # class Timer

  end # class Director

end # module WXRuby3
