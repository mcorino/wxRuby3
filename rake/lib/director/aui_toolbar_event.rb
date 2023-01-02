###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './event'

module WXRuby3

  class Director

    class AuiToolBarEvent < Event

      def setup
        super
        spec.override_inheritance_chain('wxAuiToolBarEvent',
                                        {'wxNotifyEvent' => 'wxEvents'}, {'wxCommandEvent' => 'wxEvent'}, 'wxEvent', 'wxObject')
      end
    end # class AuiToolBarEvent

  end # class Director

end # module WXRuby3
