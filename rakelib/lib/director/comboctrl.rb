# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './window'

module WXRuby3

  class Director

    class ComboCtrl < Window

      include Typemap::ComboPopup

      def setup
        super
        # mixin TextEntry
        spec.include_mixin 'wxComboCtrl', { 'Wx::TextEntry' => 'wxTextEntryBase' }
        spec.override_inheritance_chain('wxComboCtrl',
                                        %w[wxControl
                                           wxWindow
                                           wxEvtHandler
                                           wxObject])
        spec.regard %w[
          wxComboCtrl::AnimateShow
          wxComboCtrl::DoSetPopupControl
          wxComboCtrl::DoShowPopup
        ]
        spec.add_header_code <<~__HEREDOC
          #include "wxruby-ComboPopup.h"

          static VALUE g_rb_mWxComboPopup = Qnil;
          static VALUE g_rb_cComboPopupWx = Qnil;

          WXRUBY_EXPORT wxComboPopup* wxRuby_ComboPopupFromRuby(VALUE popup)
          {
            if (!NIL_P(popup) && !rb_obj_is_kind_of(popup, g_rb_mWxComboPopup))
            {
              rb_raise(rb_eArgError, "Expected a Wx::ComboPopup or nil for 1");
              return nullptr;
            }

            wxComboPopup* cpp = nullptr; 
            if (!NIL_P(popup))
            {
              VALUE rb_cp_proxy = rb_iv_get(popup, "@_wx_combo_popup_proxy");
              if (NIL_P(rb_cp_proxy))
              {
                cpp = new WxRubyComboPopup(popup);
                rb_cp_proxy = Data_Wrap_Struct(rb_cObject, 0, 0, cpp);
                rb_iv_set(popup, "@_wx_combo_popup_proxy", rb_cp_proxy);
              }
              else
              {
                Data_Get_Struct(rb_cp_proxy, wxComboPopup, cpp);
              }
            }
            return cpp;
          }

          WXRUBY_EXPORT VALUE wxRuby_ComboPopupToRuby(wxComboPopup* cpp)
          {
            VALUE rb_cpp = Qnil;
            if (cpp)
            {
              WxRubyComboPopup *wxrb_cpp = dynamic_cast<WxRubyComboPopup*> (cpp);
              if (wxrb_cpp)
              {
                rb_cpp = wxrb_cpp->GetRubyComboPopup();
              }
              else
              {
                // in this case we're probably working for a wxOwnerDrawnComboBox or wxRichTextListbox 
                // with default popup control which is a C++ implemented class without any Ruby linkage.
                // wrap this in the Wx::ComboPopupWx class to provide a Ruby interface
                rb_cpp = Data_Wrap_Struct(g_rb_cComboPopupWx, 0, 0, cpp); // do not own or track
              }
            }
            return rb_cpp;
          }

          static void wxRuby_markComboPopups()
          {
            WxRubyComboPopup::GC_mark_combo_popups();
          }
          __HEREDOC
        # ignore these
        spec.ignore 'wxComboCtrl::SetPopupControl',
                    'wxComboCtrl::GetPopupControl',
                    ignore_doc: false
        # for GetPopupControl docs only
        spec.map 'wxComboPopup*' => 'Wx::ComboPopup', swig: false do
          map_out code: ''
        end
        # and replace
        spec.add_extend_code 'wxComboCtrl', <<~__HEREDOC
          void SetPopupControl(VALUE popup)
          {
            wxComboPopup* cpp = wxRuby_ComboPopupFromRuby(popup);
            $self->SetPopupControl(cpp);
          }
      
          VALUE GetPopupControl()
          {
            return wxRuby_ComboPopupToRuby($self->GetPopupControl());
          }
          __HEREDOC
        spec.add_init_code <<~__HEREDOC
          wxRuby_AppendMarker(wxRuby_markComboPopups);

          g_rb_mWxComboPopup = rb_define_module_under(mWxCore, "ComboPopup");
          rb_define_method(g_rb_mWxComboPopup, "get_combo_ctrl", VALUEFUNC(wx_combo_popup_get_combo_ctrl), -1);

          g_rb_cComboPopupWx = rb_define_class_under(mWxCore, "ComboPopupWx", rb_cObject);
          rb_undef_alloc_func(g_rb_cComboPopupWx);
          rb_define_method(g_rb_cComboPopupWx, "lazy_create", VALUEFUNC(combo_popup_wx_lazy_create), -1);
          rb_define_method(g_rb_cComboPopupWx, "create", VALUEFUNC(combo_popup_wx_create), -1);
          rb_define_method(g_rb_cComboPopupWx, "get_combo_ctrl", VALUEFUNC(combo_popup_wx_get_combo_ctrl), -1);
          rb_define_method(g_rb_cComboPopupWx, "find_item", VALUEFUNC(combo_popup_wx_find_item), -1);
          rb_define_method(g_rb_cComboPopupWx, "get_adjusted_size", VALUEFUNC(combo_popup_wx_get_adjusted_size), -1);
          rb_define_method(g_rb_cComboPopupWx, "get_control", VALUEFUNC(combo_popup_wx_get_control), -1);
          rb_define_method(g_rb_cComboPopupWx, "set_string_value", VALUEFUNC(combo_popup_wx_set_string_value), -1);
          rb_define_method(g_rb_cComboPopupWx, "get_string_value", VALUEFUNC(combo_popup_wx_get_string_value), -1);
          rb_define_method(g_rb_cComboPopupWx, "on_combo_double_click", VALUEFUNC(combo_popup_wx_on_combo_double_click), -1);
          rb_define_method(g_rb_cComboPopupWx, "on_combo_key_event", VALUEFUNC(combo_popup_wx_on_combo_key_event), -1);
          rb_define_method(g_rb_cComboPopupWx, "on_combo_char_event", VALUEFUNC(combo_popup_wx_on_combo_char_event), -1);
          rb_define_method(g_rb_cComboPopupWx, "on_dismiss", VALUEFUNC(combo_popup_wx_on_dismiss), -1);
          rb_define_method(g_rb_cComboPopupWx, "on_popup", VALUEFUNC(combo_popup_wx_on_popup), -1);
          rb_define_method(g_rb_cComboPopupWx, "paint_combo_control", VALUEFUNC(combo_popup_wx_paint_combo_control), -1);
          __HEREDOC
      end

    end # class ComboCtrl

  end # class Director

end # module WXRuby3
