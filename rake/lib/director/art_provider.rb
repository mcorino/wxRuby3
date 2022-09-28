#--------------------------------------------------------------------
# @file    art_provider.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

module WXRuby3

  class Director

    class ArtProvider < Director

      def setup
        spec.rename('wxArtProvider' => 'wxRubyArtProvider')
        spec.rename_class('wxArtProvider', 'wxRubyArtProvider')
        spec.ignore('wxArtProvider::CreateBitmap') # must be supplied in ruby
        spec.ignore('wxArtProvider::Insert') # deprecated and problematic
        spec.no_proxy('wxRubyArtProvider')
        spec.include('wx/artprov.h')
        spec.add_swig_begin_code <<~__HEREDOC
          // ArtId and ArtClient are basically just strings ...
          typedef wxString wxArtID;
          typedef wxString wxArtClient;
          // ... but because they are used only in static methods, which have one
          // fewer argument (no "self") than instance methods, we need to do
          // deletion differently from the standard technique in typemap.i
          %typemap(freearg) wxString& "if ( argc > $argnum - 1 ) delete $1;";
          
          %apply SWIGTYPE *DISOWN {wxArtProvider* provider};
          __HEREDOC
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
