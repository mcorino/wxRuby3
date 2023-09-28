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
        # create a lightweight, but typesafe, wrapper for wxEventId
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
          static size_t __wxTreeEventId_size(const void* data)
          {
            return 0;
          }

          #include <ruby/version.h> 

          static const rb_data_type_t __wxTreeEventId_type = {
            "TreeEventId",
          #if RUBY_API_VERSION_MAJOR >= 3
            { NULL, NULL, __wxTreeEventId_size, 0, 0},
          #else
            { NULL, NULL, __wxTreeEventId_size, 0},
          #endif 
            NULL, NULL, RUBY_TYPED_FREE_IMMEDIATELY
          };

          VALUE _wxRuby_Wrap_wxTreeItemId(const wxTreeItemId& id)
          {
            void* data = id.GetID();
            VALUE ret = TypedData_Wrap_Struct(mWxTreeItemId, &__wxTreeEventId_type, data);
            return ret;
          } 

          wxTreeItemId _wxRuby_Unwrap_wxTreeItemId(VALUE id)
          {
            void *data = 0;
            TypedData_Get_Struct(id, void, &__wxTreeEventId_type, data);
            return wxTreeItemId(data);
          }

          VALUE _wxRuby_wxTreeItemId_IsOk(VALUE self)
          {
            void *data = 0;
            TypedData_Get_Struct(self, void, &__wxTreeEventId_type, data);
            return wxTreeItemId(data).IsOk() ? Qtrue : Qfalse;
          }
          __HEREDOC
      end
    end # class TreeEvent

  end # class Director

end # module WXRuby3
