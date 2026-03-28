# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './event'

module WXRuby3

  class Director

    class ThreadEvent < Event

      def setup
        super
        spec.gc_as_marked # use marked so doc gen does not mark it as untracked (what it actually is)
        spec.ignore 'wxThreadEvent::GetPayload',
                    'wxThreadEvent::SetPayload',
                    'wxThreadEvent::GetEventCategory'
        spec.add_swig_code %Q{%constant wxEventType wxEVT_THREAD = wxEVT_THREAD;}
        spec.do_not_generate(:variables, :defines, :enums, :functions)
      end

    end # class ThreadEvent

  end # class Director

end # module WXRuby3
