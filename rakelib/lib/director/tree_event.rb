# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './event'

module WXRuby3

  class Director

    class TreeEvent < Event

      include Typemap::TreeItemId

      def setup
        super
        # for wxTreeEvent::GetKeyEvent
        spec.map 'const wxKeyEvent&' => 'Wx::KeyEvent' do
          map_out code: <<~__CODE
            #ifdef __WXRB_DEBUG__
            $result = wxRuby_WrapWxEventInRuby(arg1, static_cast<wxEvent*> ($1));
            #else
            $result = wxRuby_WrapWxEventInRuby(static_cast<wxEvent*> ($1));
            #endif
            __CODE
        end
        # create a lightweight, but typesafe, wrapper for TreeItemId
        spec.add_init_code <<~__HEREDOC
          // define TreeItemId wrapper class
          mWxTreeItemId = rb_define_class_under(mWxCore, "TreeItemId", rb_cObject);
          rb_undef_alloc_func(mWxTreeItemId);
          rb_define_method(mWxTreeItemId, "is_ok", VALUEFUNC(_wxRuby_wxTreeItemId_IsOk), 0);
          rb_define_method(mWxTreeItemId, "ok?", VALUEFUNC(_wxRuby_wxTreeItemId_IsOk), 0);
          __HEREDOC

        spec.add_header_code <<~__HEREDOC
          VALUE mWxTreeItemId;
          VALUE _wxRuby_Wrap_wxTreeItemId(const wxTreeItemId& id);
          wxTreeItemId _wxRuby_Unwrap_wxTreeItemId(VALUE id);
          __HEREDOC
        
        spec.add_wrapper_code <<~__HEREDOC
          // wxTreeItemId wrapper class definition and helper functions
          static size_t __wxTreeItemId_size(const void* data)
          {
            return 0;
          }

          #include <ruby/version.h> 

          static const rb_data_type_t __wxTreeItemId_type = {
            "TreeItemId",
          #if RUBY_API_VERSION_MAJOR >= 3
            { NULL, NULL, __wxTreeItemId_size, 0, {}},
          #else
            { NULL, NULL, __wxTreeItemId_size, {}},
          #endif 
            NULL, NULL, RUBY_TYPED_FREE_IMMEDIATELY
          };

          VALUE _wxRuby_Wrap_wxTreeItemId(const wxTreeItemId& id)
          {
            void* data = id.GetID();
            VALUE ret = TypedData_Wrap_Struct(mWxTreeItemId, &__wxTreeItemId_type, data);
            return ret;
          } 

          wxTreeItemId _wxRuby_Unwrap_wxTreeItemId(VALUE id)
          {
            void *data = 0;
            TypedData_Get_Struct(id, void, &__wxTreeItemId_type, data);
            return wxTreeItemId(data);
          }

          bool _wxRuby_Is_wxTreeItemId(VALUE id)
          {
            return rb_typeddata_is_kind_of(id, &__wxTreeItemId_type) == 1;
          } 

          VALUE _wxRuby_wxTreeItemId_IsOk(VALUE self)
          {
            void *data = 0;
            TypedData_Get_Struct(self, void, &__wxTreeItemId_type, data);
            return wxTreeItemId(data).IsOk() ? Qtrue : Qfalse;
          }
          __HEREDOC
      end
    end # class TreeEvent

  end # class Director

end # module WXRuby3
