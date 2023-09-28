# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
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
