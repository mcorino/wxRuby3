# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './window'

module WXRuby3

  class Director

    class BackstageMRUList < Window

      include Typemap::DateTime

      def setup
        super
        spec.gc_as_window 'wxBackstageMRUList'
        spec.no_proxy('wxBackstageMRUList')
        spec.override_inheritance_chain('wxBackstageMRUList', %w[wxBackstageItemList wxScrolledCanvas wxWindow wxEvtHandler wxObject])
        spec.ignore 'wxBackstageMRUList::SetIconProvider'
        spec.add_header_code <<~__HEREDOC
          // define Ruby Icon Provider wrapper function object
          class RbIconProvider 
          {
            public:

            RbIconProvider(VALUE rbip) : rbIconProvider_(rbip) {}

            wxBitmapBundle operator() (const wxString& p) 
            {
                static WxRuby_ID call_id("call");
                static WxRuby_ID bitmap_bundle_id("BitmapBundle");
                static WxRuby_ID bitmap_id("Bitmap");
                static WxRuby_ID icon_id("Icon");
                static WxRuby_ID image_id("Image");
    
                bool ex_caught = false;
                wxBitmapBundle tmpBundle;
                if (!NIL_P(rbIconProvider_))
                {
                  VALUE rc = wxRuby_Funcall(ex_caught, rbIconProvider_, call_id(), 1, WXSTR_TO_RSTR(p));
                  if (ex_caught)
                  {
          #ifdef __WXRB_DEBUG__                
                    if (!rb_obj_is_kind_of(rc, rb_eSystemExit))
                    {
                      wxRuby_PrintException(rc);
                    }
          #endif
                    wxRuby_ExitMainLoop(rc);
                  }
                  if (!NIL_P(rc))
                  {
                    bool ok = false;
                    if (TYPE(rc) == T_DATA) 
                    {
                      void *ptr = WXRUBY_WRAPPER_DATA_GET(rc, void);
                      if (ptr)
                      {
                        ok = true;
                        if (isClass(rc, bitmap_bundle_id()))
                          tmpBundle = *static_cast<wxBitmapBundle*> (ptr);
                        else if (isClass(rc, bitmap_id()))
                          tmpBundle = wxBitmapBundle(*static_cast<wxBitmap*> (ptr)); 
                        else if (isClass(rc, icon_id()))
                          tmpBundle = wxBitmapBundle(*static_cast<wxIcon*> (ptr)); 
                        else if (isClass(rc, image_id()))
                          tmpBundle = wxBitmapBundle(*static_cast<wxImage*> (ptr));
                        else
                          ok = false;
                      }
                    }

                    if (!ok)
                    {  
                      std::wcerr << "Invalid return value from icon provider" << std::endl;
                      wxRuby_ExitMainLoop();
                    }
                  }
                }
                return tmpBundle;
            } 
          
            private:

            VALUE rbIconProvider_ {};

            inline bool isClass(VALUE obj, ID class_id)
            {
              VALUE klass = rb_const_get(wxRuby_Core(), class_id);
              return rb_obj_is_kind_of(obj, klass);
            }
          };
          __HEREDOC
        spec.add_extend_code 'wxBackstageMRUList', <<~__CODE
          void set_icon_provider(VALUE provider)
          {
            std::function<wxBitmapBundle(const wxString&)> icon_provider_func = RbIconProvider(provider);
            $self->SetIconProvider(icon_provider_func);
          }
          __CODE
        spec.do_not_generate :variables, :enums, :defines, :functions, :typedefs
      end
    end # class BackstageMRUList

  end # class Director

end # module WXRuby3
