# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

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
