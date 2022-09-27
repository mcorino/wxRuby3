#--------------------------------------------------------------------
# @file    book_ctrl_event.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

require_relative './event'

module WXRuby3

  class Director

    class BookCtrlEvent < Event

      def setup
        super
        spec.ignore_bases('wxBookCtrlEvent' => %w[wxNotifyEvent wxCommandEvent]) # needed to suppress imports
        spec.swig_import('swig/classes/include/wxObject.h', 'swig/classes/include/wxEvent.h') # provide base definitions
        case spec.module_name
        when 'wxBookCtrlEvent'
          spec.override_base('wxBookCtrlEvent', 'wxNotifyEvent') # re-establish correct base
          spec.include('wx/bookctrl.h')
        end
      end
    end # class Object

  end # class Director

end # module WXRuby3
