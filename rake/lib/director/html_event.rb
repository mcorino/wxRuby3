###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './event'

module WXRuby3

  class Director

    class HtmlEvent < Event

      include Typemap::HtmlCell

      def setup
        super
        spec.do_not_generate :variables, :enums, :defines, :functions
      end
    end # class HtmlEvent

  end # class Director

end # module WXRuby3
