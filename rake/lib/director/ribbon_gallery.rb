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
        spec.ignore 'wxRibbonGallery::SetItemClientObject',
                    'wxRibbonGallery::GetItemClientObject'
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

          VALUE _wxRuby_Wrap_wxRibbonGalleryItem(const wxRibbonGalleryItem* itm)
          {
            VALUE obj = Qnil;
            if (itm)
            {
              void *ptr = const_cast<wxRibbonGalleryItem*> (itm);
              obj = TypedData_Wrap_Struct(mWxRibbonGalleryItem, &__wxRibbonGalleryItem_type, ptr);
            }
            return obj;
          } 

          wxRibbonGalleryItem* _wxRuby_Unwrap_wxRibbonGalleryItem(VALUE itm)
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
          map_directorin code: '$result = _wxRuby_Wrap_wxRibbonGalleryItem($1);'
        end
        # GC handling for item data objects.
        spec.add_header_code <<~__HEREDOC
          // SWIG's entry point function for GC mark
          static void GC_mark_wxRibbonGallery(void *ptr)
          {
            if ( GC_IsWindowDeleted(ptr) )
              return;
        
            // Do standard marking routines as for all wxWindows
            GC_mark_wxWindow(ptr);
        
            wxRibbonGallery* wx_rg = (wxRibbonGallery*) ptr;

            for (unsigned int i=0; i<wx_rg->GetCount(); ++i)
            {
              wxRibbonGalleryItem* wx_rgi = wx_rg->GetItem(i);
              void* data = wx_rg->GetItemClientData(wx_rgi);
              if (data) rb_gc_mark((VALUE)data);
            }          
          }
          __HEREDOC
        spec.add_swig_code '%markfunc wxRibbonGallery "GC_mark_wxRibbonGallery";'
      end
    end # class RibbonGallery

  end # class Director

end # module WXRuby3
