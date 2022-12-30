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
        if Config.instance.wx_version > '3.1.5'
          # because of error in XML docs
          spec.ignore('wxSplitterEvent::GetOldSize', ignore_doc: false)
          # add these by hand here
          spec.extend_interface('wxSplitterEvent',
                                'int GetOldSize() const',
                                'int GetNewSize() const')
        end
        spec.do_not_generate(:variables, :enums, :defines, :functions)
      end
    end # class SplitterEvent

  end # class Director

end # module WXRuby3
