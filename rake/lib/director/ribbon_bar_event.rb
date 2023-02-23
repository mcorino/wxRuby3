###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './event'

module WXRuby3

  class Director

    class RibbonBarEvent < Event

      def setup
        super
        spec.override_inheritance_chain('wxRibbonBarEvent',
                                        {'wxNotifyEvent' => 'wxEvents'}, {'wxCommandEvent' => 'wxEvent'}, 'wxEvent', 'wxObject')
        spec.do_not_generate :variables, :enums, :defines, :functions
      end
    end # class RibbonBarEvent

  end # class Director

end # module WXRuby3
