###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './event'

module WXRuby3

  class Director

    class RibbonPanelEvent < Event

      def setup
        super
        spec.override_inheritance_chain('wxRibbonPanelEvent',
                                        {'wxCommandEvent' => 'wxEvent'}, 'wxEvent', 'wxObject')
        spec.do_not_generate :variables, :enums, :defines, :functions
      end
    end # class RibbonPanelEvent

  end # class Director

end # module WXRuby3
