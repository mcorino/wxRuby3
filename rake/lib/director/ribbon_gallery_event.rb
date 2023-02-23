###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './event'

module WXRuby3

  class Director

    class RibbonGalleryEvent < Event

      def setup
        super
        spec.override_inheritance_chain('wxRibbonGalleryEvent',
                                        {'wxCommandEvent' => 'wxEvent'}, 'wxEvent', 'wxObject')
        spec.do_not_generate :variables, :enums, :defines, :functions
      end
    end # class RibbonGalleryEvent

  end # class Director

end # module WXRuby3
