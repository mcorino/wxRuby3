#--------------------------------------------------------------------
# @file    richtext_event.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

require_relative './event'

module WXRuby3

  class Director

    class RichTextEvent < Event

      include Typemap::RichText # for wxRichTextRange

      def setup
        super
        spec.ignore 'wxRichTextEvent::Clone'
        spec.disable_proxies
      end
    end # class RichTextEvent

  end # class Director

end # module WXRuby3
