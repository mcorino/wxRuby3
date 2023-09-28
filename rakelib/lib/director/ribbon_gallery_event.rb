# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './event'

module WXRuby3

  class Director

    class RibbonGalleryEvent < Event

      def setup
        super
        # map opaque wxRibbonGalleryItem* to an pointer sized integer value
        spec.map 'wxRibbonGalleryItem*' => 'Integer' do
          map_out code: '$result = ULL2NUM(reinterpret_cast<uintptr_t> ($1));'
          map_in code: '$1 = reinterpret_cast<wxRibbonGalleryItem*> ((uintptr_t)NUM2ULL($input));'
        end
        spec.do_not_generate :variables, :enums, :defines, :functions
      end
    end # class RibbonGalleryEvent

  end # class Director

end # module WXRuby3
