###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './window'

module WXRuby3

  class Director

    class RibbonGallery < Window

      def setup
        super
        # exclude these; far better done in pure Ruby
        spec.ignore 'wxRibbonGallery::SetItemClientObject',
                    'wxRibbonGallery::GetItemClientObject'
        spec.ignore 'wxRibbonGallery::SetItemClientData',
                    'wxRibbonGallery::GetItemClientData', ignore_doc: false
        spec.map 'wxRibbonGalleryItem*' => 'Integer' do
          map_out code: '$result = ULL2NUM(reinterpret_cast<uintptr_t> ($1));'
          map_directorout code: '$result = reinterpret_cast<wxRibbonGalleryItem*> ((uintptr_t)NUM2ULL($1));'
          map_in code: '$1 = reinterpret_cast<wxRibbonGalleryItem*> ((uintptr_t)NUM2ULL($input));'
          map_directorin code: '$input = ULL2NUM(reinterpret_cast<uintptr_t> ($1));'
          map_typecheck precedence: 'INTEGER', code: '$1 = (TYPE($input) == T_FIXNUM);'
        end
      end
    end # class RibbonGallery

  end # class Director

end # module WXRuby3
