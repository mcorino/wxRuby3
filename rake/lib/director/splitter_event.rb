#--------------------------------------------------------------------
# @file    splitter_event.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

require_relative './event'

module WXRuby3

  class Director

    class SplitterEvent < Event

      def setup
        super
        spec.ignore_bases('wxSplitterEvent' => %w[wxNotifyEvent]) # needed to suppress imports
        spec.swig_import('swig/classes/include/wxObject.h', 'swig/classes/include/wxEvent.h') # provide base definitions
        spec.override_base('wxSplitterEvent', 'wxNotifyEvent') # re-establish correct base
        # because of error in XML docs
        spec.ignore('wxSplitterEvent::GetOldSize', ignore_doc: false)
        # add these by hand here
        spec.extend_interface('wxSplitterEvent',
                              'int GetOldSize() const',
                              'int GetNewSize() const')
        spec.do_not_generate(:variables, :enums, :defines, :functions)
      end
    end # class SplitterEvent

  end # class Director

end # module WXRuby3
