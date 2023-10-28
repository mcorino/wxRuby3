# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './event'

module WXRuby3

  class Director

    class FileCtrlEvent < Event

      def setup
        super
        spec.disable_proxies
        spec.do_not_generate(:variables, :defines, :enums, :functions) # with FileCtrl
      end
    end # class FileCtrlEvent

  end # class Director

end # module WXRuby3
