###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class ArtProvider < Director

      def setup
        spec.make_concrete('wxArtProvider')
        # make Ruby director and wrappers use custom implementation
        spec.use_class_implementation('wxArtProvider', 'wxRubyArtProvider')
        spec.ignore('wxArtProvider::Insert') # deprecated and problematic
        spec.ignore('wxArtProvider::Remove') # problematic as adding disowns the art provider, use Delete
        spec.no_proxy('wxArtProvider')
        spec.include('wx/artprov.h')
        spec.add_swig_code <<~__HEREDOC
          // ArtId and ArtClient are basically just strings ...
          typedef wxString wxArtID;
          typedef wxString wxArtClient;
          __HEREDOC
        spec.map *%w[wxArtID wxArtClient], as: 'String', swig: false do
          map_in
          map_out
        end
        spec.map_apply 'SWIGTYPE *DISOWN' => 'wxArtProvider* provider'
        spec.add_header_code <<~__HEREDOC
          extern swig_class SwigClassWxSize;
          extern swig_class SwigClassWxObject;
          
          class wxRubyArtProvider : public wxArtProvider
          {
          public:
            wxSize DoGetSizeHint (const wxArtClient &client) override
            {
              VALUE v_client, v_ret;
          
              VALUE self = SWIG_RubyInstanceFor(this);

              v_client = WXSTR_TO_RSTR(client);
              v_ret = rb_funcall(self,rb_intern("do_get_size_hint"),1, v_client);
              if ( TYPE(v_ret) == T_DATA )
              {
                void* ptr;
                SWIG_ConvertPtr(v_ret, &ptr, SWIGTYPE_p_wxSize, 1);
                return *reinterpret_cast< wxSize * >(ptr);
              }
              else if ( TYPE(v_ret) == T_ARRAY )
              {
                return wxSize( NUM2INT( rb_ary_entry(v_ret, 0) ),
                               NUM2INT( rb_ary_entry(v_ret, 1) ) );
              }
              else
              {
                return wxSize(-1, -1);
              }
            }          

            wxBitmap CreateBitmap(const wxArtID& id, const wxArtClient& client, const wxSize& size) override
            {
              VALUE v_id,v_client,v_size,v_ret;
          
              VALUE self = SWIG_RubyInstanceFor(this);
          
              v_id     = WXSTR_TO_RSTR(id);
              v_client = WXSTR_TO_RSTR(client);
              v_size = SWIG_NewPointerObj(SWIG_as_voidptr(&size), SWIGTYPE_p_wxSize, 0);
              v_ret = rb_funcall(self,rb_intern("create_bitmap"),3,v_id,v_client,v_size);
          
              if (v_ret != Qnil) 
                return *((wxBitmap *)DATA_PTR(v_ret));
              else
                return wxNullBitmap;
            }

            wxBitmapBundle CreateBitmapBundle(const wxArtID& id, const wxArtClient& client, const wxSize& size) override
            {
              VALUE v_id,v_client,v_size,v_ret;
          
              VALUE self = SWIG_RubyInstanceFor(this);
          
              v_id     = WXSTR_TO_RSTR(id);
              v_client = WXSTR_TO_RSTR(client);
              v_size = SWIG_NewPointerObj(SWIG_as_voidptr(&size), SWIGTYPE_p_wxSize, 0);
              v_ret = rb_funcall(self,rb_intern("create_bitmap_bundle"),3,v_id,v_client,v_size);
          
              if (v_ret != Qnil) 
                return *((wxBitmapBundle *)DATA_PTR(v_ret));
              else
                return wxBitmapBundle();
            }

            wxIconBundle CreateIconBundle(const wxArtID &id, const wxArtClient &client) override
            {
              VALUE v_id,v_client,v_ret;
          
              VALUE self = SWIG_RubyInstanceFor(this);
          
              v_id     = WXSTR_TO_RSTR(id);
              v_client = WXSTR_TO_RSTR(client);
            
              v_ret = rb_funcall(self,rb_intern("create_icon_bundle"),2,v_id,v_client);
          
              if (v_ret != Qnil) 
                return *((wxIconBundle *)DATA_PTR(v_ret));
              else
                return wxIconBundle();
            }
          };
          __HEREDOC
        super
      end
    end # class ArtProvider

  end # class Director

end # module WXRuby3
