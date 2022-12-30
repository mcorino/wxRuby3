###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class ArtProvider < Director

      def setup
        spec.rename_for_ruby('wxArtProvider' => 'wxRubyArtProvider')
        spec.rename_class('wxArtProvider', 'wxRubyArtProvider')
        spec.ignore('wxArtProvider::CreateBitmap') # must be supplied in ruby
        spec.ignore('wxArtProvider::Insert') # deprecated and problematic
        spec.no_proxy('wxRubyArtProvider')
        spec.include('wx/artprov.h')
        spec.add_swig_code <<~__HEREDOC
          // ArtId and ArtClient are basically just strings ...
          typedef wxString wxArtID;
          typedef wxString wxArtClient;
          __HEREDOC
        spec.map_apply 'SWIGTYPE *DISOWN' => 'wxArtProvider* provider'
        spec.add_header_code <<~__HEREDOC
          extern swig_class SwigClassWxSize;
          extern swig_class SwigClassWxObject;
          
          class wxRubyArtProvider : public wxArtProvider
          {
            public:
          
            wxBitmap CreateBitmap(const wxArtID& id, const wxArtClient& client, const wxSize& size)
            {
              VALUE v_id,v_client,v_size,v_ret;
              wxBitmap result;
          
            VALUE self = SWIG_RubyInstanceFor(this);
          
              v_id     = WXSTR_TO_RSTR(id);
              v_client = WXSTR_TO_RSTR(client);
              v_size   = SWIG_NewClassInstance(SwigClassWxSize.klass, SWIGTYPE_p_wxSize);
              wxSize *size_ptr = new wxSize(size);
              DATA_PTR(v_size) = size_ptr;
            
              v_ret = rb_funcall(self,rb_intern("create_bitmap"),3,v_id,v_client,v_size);
          
              if (v_ret != Qnil) 
                result = *((wxBitmap *)DATA_PTR(v_ret));
              else
                return wxNullBitmap;
              return result;
            }
          };
          __HEREDOC
        super
      end
    end # class ArtProvider

  end # class Director

end # module WXRuby3
