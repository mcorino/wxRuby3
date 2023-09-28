# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './event'

module WXRuby3

  class Director

    class AuiNotebookEvent < Event

      def setup
        super
        spec.override_inheritance_chain('wxAuiNotebookEvent',
                                        'wxBookCtrlEvent', {'wxNotifyEvent' => 'wxEvents'}, {'wxCommandEvent' => 'wxEvent'}, 'wxEvent', 'wxObject')
      end
    end # class AuiNotebookEvent

  end # class Director

end # module WXRuby3
