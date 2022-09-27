#--------------------------------------------------------------------
# @file    spinevent.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

require_relative './event'

module WXRuby3

  class Director

    class SpinEvent < Event

      def setup
        super
        spec.ignore_bases('wxSpinEvent' => %w[wxNotifyEvent]) # needed to suppress imports
        spec.swig_import('swig/classes/include/wxObject.h', 'swig/classes/include/wxEvent.h') # provide base definitions
        spec.override_base('wxSpinEvent', 'wxNotifyEvent') # re-establish correct base
      end
    end # class SpinEvent

  end # class Director

end # module WXRuby3
