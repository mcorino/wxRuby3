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
        spec.map 'wxRibbonGalleryItem*' => 'Wx::RBN::RibbonGalleryItem' do
          add_header_code <<~__CODE
            extern VALUE _wxRuby_Wrap_wxRibbonGalleryItem(const wxRibbonGalleryItem* itm);
            extern wxRibbonGalleryItem* _wxRuby_Unwrap_wxRibbonGalleryItem(VALUE itm);
            __CODE
          map_in code: '$1 = _wxRuby_Unwrap_wxRibbonGalleryItem($input);'
          map_out code: '$result = _wxRuby_Wrap_wxRibbonGalleryItem($1);'
        end
        spec.do_not_generate :variables, :enums, :defines, :functions
      end
    end # class RibbonGalleryEvent

  end # class Director

end # module WXRuby3
