#--------------------------------------------------------------------
# @file    wizard_event.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

require_relative './event'

module WXRuby3

  class Director

    class WizardEvent < Event

      def setup
        super
      end
    end # class WizardEvent

  end # class Director

end # module WXRuby3
