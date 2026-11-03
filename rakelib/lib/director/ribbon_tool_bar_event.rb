# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './event'

module WXRuby3

  class Director

    class RibbonToolBarEvent < Event

      def setup
        super
        # disable the common wxMenu* typemap for wxRibbonToolBarEvent::PopupMenu as that does not take ownership of
        # the passed wxMenu and also does not expose the wxMenu in Ruby during execution
        # (prevents leaking popup menus)
        spec.map_disable 'wxMenu*'
        spec.do_not_generate :variables, :enums, :defines, :functions
      end
    end # class RibbonToolBarEvent

  end # class Director

end # module WXRuby3
