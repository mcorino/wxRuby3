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
        # create a lightweight, but typesafe, wrapper for wxRibbonGalleryItem
        spec.add_init_code <<~__HEREDOC
          // define RibbonGalleryItem wrapper class
          mWxRibbonGalleryItem = rb_define_class_under(mWxRibbonGallery, "RibbonGalleryItem", rb_cObject);
          rb_undef_alloc_func(mWxRibbonGalleryItem);
        __HEREDOC

        spec.add_header_code <<~__HEREDOC
          VALUE mWxRibbonGalleryItem;
          VALUE _wxRuby_Wrap_wxRibbonGalleryItem(const wxRibbonGalleryItem* itm);
          wxRibbonGalleryItem* _wxRuby_Unwrap_wxRibbonGalleryItem(VALUE itm);
        __HEREDOC

        spec.add_wrapper_code <<~__HEREDOC
          // wxRibbonGalleryItem wrapper class definition and helper functions
          static size_t __wxRibbonGalleryItem_size(const void* data)
          {
            return 0;
          }

          #include <ruby/version.h> 

          static const rb_data_type_t __wxRibbonGalleryItem_type = {
            "RibbonGalleryItem",
          #if RUBY_API_VERSION_MAJOR >= 3
            { NULL, NULL, __wxRibbonGalleryItem_size, 0, 0},
          #else
            { NULL, NULL, __wxRibbonGalleryItem_size, 0},
          #endif 
            NULL, NULL, RUBY_TYPED_FREE_IMMEDIATELY
          };

          extern VALUE _wxRuby_Wrap_wxRibbonGalleryItem(const wxRibbonGalleryItem* itm)
          {
            VALUE obj = Qnil;
            if (itm)
            {
              void *ptr = const_cast<wxRibbonGalleryItem*> (itm);
              obj = TypedData_Wrap_Struct(mWxRibbonGalleryItem, &__wxRibbonGalleryItem_type, ptr);
            }
            return obj;
          } 

          extern wxRibbonGalleryItem* _wxRuby_Unwrap_wxRibbonGalleryItem(VALUE itm)
          {
            void *data = 0;
            if (!NIL_P(itm))
            {
              TypedData_Get_Struct(itm, void, &__wxRibbonGalleryItem_type, data);
            }
            return reinterpret_cast<wxRibbonGalleryItem*> (data);
          }
          __HEREDOC
        spec.map 'wxRibbonGalleryItem*' => 'Wx::RBN::RibbonGalleryItem' do
          map_in code: '$1 = _wxRuby_Unwrap_wxRibbonGalleryItem($input);'
          map_out code: '$result = _wxRuby_Wrap_wxRibbonGalleryItem($1);'
          map_directorin code: '$input = _wxRuby_Wrap_wxRibbonGalleryItem($1);'
          map_directorout code: '$result = _wxRuby_Unwrap_wxRibbonGalleryItem($1);'
        end
      end
    end # class RibbonGallery

  end # class Director

end # module WXRuby3
