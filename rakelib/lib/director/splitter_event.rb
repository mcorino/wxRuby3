###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './event'

module WXRuby3

  class Director

    class SplitterEvent < Event

      def setup
        super
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
