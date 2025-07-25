# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './window'

module WXRuby3

  class Director

    class AuiTabCtrl < Director

      def setup
        super
        spec.items.clear
        # create a lightweight, but typesafe, wrapper for AuiTabCtrl
        spec.add_init_code <<~__HEREDOC
          // define AuiTabCtrl wrapper class
          VALUE cWxAuiTabCtrl = rb_define_class_under(mWxAUI, "AuiTabCtrl", rb_cObject);
          rb_undef_alloc_func(cWxAuiTabCtrl);
          rb_define_method(cWxAuiTabCtrl, "is_ok", VALUEFUNC(_wxRuby_wxAuiTabCtrl_IsOk), 0);
          rb_define_method(cWxAuiTabCtrl, "ok?", VALUEFUNC(_wxRuby_wxAuiTabCtrl_IsOk), 0);
          rb_define_method(cWxAuiTabCtrl, "==", VALUEFUNC(_wxRuby_wxAuiTabCtrl_IsEqual), 1);
          rb_define_alias(cWxAuiTabCtrl, "eql?", "==");
          __HEREDOC

        spec.add_header_code <<~__HEREDOC
          #include <wx/aui/auibook.h>

          VALUE _wxRuby_Wrap_wxAuiTabCtrl(const wxAuiTabCtrl& rbATC);
          wxAuiTabCtrl* _wxRuby_Unwrap_wxAuiTabCtrl(VALUE rbATC);
          __HEREDOC

        spec.add_wrapper_code <<~__HEREDOC
          // wxAuiTabCtrl wrapper class definition and helper functions
          static size_t __wxAuiTabCtrl_size(const void* data)
          {
            return 0;
          }

          #include <ruby/version.h> 

          static const rb_data_type_t __wxAuiTabCtrl_type = {
            "AuiTabCtrl",
          #if RUBY_API_VERSION_MAJOR >= 3
            { NULL, NULL, __wxAuiTabCtrl_size, 0, {}},
          #else
            { NULL, NULL, __wxAuiTabCtrl_size, {}},
          #endif 
            NULL, NULL, RUBY_TYPED_FREE_IMMEDIATELY
          };

          VALUE _wxRuby_Wrap_wxAuiTabCtrl(wxAuiTabCtrl* wxATC)
          {
            VALUE ret = TypedData_Wrap_Struct(mWxAuiTabCtrl, &__wxAuiTabCtrl_type, wxATC);
            return ret;
          } 

          wxAuiTabCtrl* _wxRuby_Unwrap_wxAuiTabCtrl(VALUE rbATC)
          {
            wxAuiTabCtrl* wxATC = nullptr;
            TypedData_Get_Struct(rbATC, wxAuiTabCtrl, &__wxAuiTabCtrl_type, wxATC);
            return wxATC;
          }

          bool _wxRuby_Is_wxAuiTabCtrl(VALUE rbATC)
          {
            return rb_typeddata_is_kind_of(rbATC, &__wxAuiTabCtrl_type) == 1;
          } 

          VALUE _wxRuby_wxAuiTabCtrl_IsOk(VALUE self)
          {
            wxAuiTabCtrl* wxATC = _wxRuby_Unwrap_wxAuiTabCtrl(self);
            return wxATC ? Qtrue : Qfalse;
          }

          VALUE _wxRuby_wxAuiTabCtrl_IsEqual(VALUE self, VALUE other)
          {
            return rb_typeddata_is_kind_of(other, &__wxAuiTabCtrl_type) == 1 && 
                _wxRuby_Unwrap_wxAuiTabCtrl(self) == _wxRuby_Unwrap_wxAuiTabCtrl(other);
          } 
          __HEREDOC
      end
    end # class AuiTabCtrl

  end # class Director

end # module WXRuby3
