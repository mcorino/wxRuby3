#--------------------------------------------------------------------
# @file    listevent.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

require_relative './event'

module WXRuby3

  class Director

    class ListEvent < Event

      def setup
        super
        spec.ignore_bases('wxListEvent' => %w[wxNotifyEvent]) # needed to suppress imports
        spec.swig_import('swig/classes/include/wxObject.h', 'swig/classes/include/wxEvent.h', append_to_base_imports: true) # provide base definitions
        spec.override_base('wxListEvent', 'wxNotifyEvent') # re-establish correct base
      end
    end # class ListEvent

  end # class Director

end # module WXRuby3
