# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class Image < Director

      include Typemap::IOStreams

      def setup
        super
        # Handled in Ruby: lib/wx/classes/image.rb
        spec.ignore [
          'wxImage::wxImage(wxInputStream &,wxBitmapType,int)',
          'wxImage::wxImage(wxInputStream &,const wxString &,int)',
          'wxImage::wxImage(const char *const *)',
          'wxImage::GetImageCount(wxInputStream &,wxBitmapType)'
          ]
        # ignore original signature
        spec.ignore 'wxImage::SetAlpha(unsigned char *,bool)', ignore_doc: false
        # add custom signature to aid type mapping
        spec.extend_interface 'wxImage', 'void SetAlpha(unsigned char *alpha_or_null=NULL, bool static_data=false)'
        spec.rename_for_ruby(
          'LoadStream' => ['wxImage::LoadFile(wxInputStream &, wxBitmapType, int)', 'wxImage::LoadFile(wxInputStream &,const wxString &, int)'],
          'Write' => ['wxImage::SaveFile(wxOutputStream &, wxBitmapType) const', 'wxImage::SaveFile(wxOutputStream &,const wxString &) const'],
          # Renaming to avoid method overloading and thus conflicts at Ruby level
          # 'GetAlphaData' => 'wxImage::GetAlpha() const',
          'SetAlphaData' => 'wxImage::SetAlpha(unsigned char *,bool)',
          # Renaming for consistency with above methods and SetRGB method
          # 'GetRgbData' => 'wxImage::GetData() const',
          'SetRgbDataWithSize' => 'wxImage::SetData(unsigned char *,int,int,bool)')
        # handle this in Ruby
        spec.ignore 'wxImage::SetData(unsigned char *,bool)'
        # Handler methods are not supported in wxRuby; all standard handlers
        # are loaded at startup, and we don't allow custom image handlers to be
        # written in Ruby.
        spec.ignore %w[
          wxImage::AddHandler
          wxImage::CleanUpHandlers
          wxImage::FindHandler
          wxImage::FindHandlerMime
          wxImage::GetHandlers
          wxImage::InitStandardHandlers
          wxImage::InsertHandler
          wxImage::RemoveHandler
          ]
        # add convenience class methods
        spec.add_extend_code 'wxImage', <<~__HEREDOC
          static VALUE handlers()
          {
            VALUE hnd_ary = rb_ary_new();
            wxList& hnd_lst = wxImage::GetHandlers();
            for (wxList::compatibility_iterator node = hnd_lst.GetFirst();
                    node; node = node->GetNext())
            {
              wxImageHandler *handler = (wxImageHandler *) node->GetData();
              wxBitmapType bmp_type = handler->GetType();
              rb_ary_push(hnd_ary, wxRuby_GetEnumValueObject("wxBitmapType", (int)bmp_type));
            }
            return hnd_ary;
          }

          static VALUE extensions()
          {
            VALUE ext_ary = rb_ary_new();
            wxList& hnd_lst = wxImage::GetHandlers();
            for (wxList::compatibility_iterator node = hnd_lst.GetFirst();
                    node; node = node->GetNext())
            {
              wxImageHandler *handler = (wxImageHandler *) node->GetData();
              rb_ary_push(ext_ary, WXSTR_TO_RSTR(handler->GetExtension()));
              const wxArrayString& alt_ext = handler->GetAltExtensions();
              for (wxArrayString::const_iterator it = alt_ext.begin(); it!=alt_ext.end() ;++it)
              {
                rb_ary_push(ext_ary, WXSTR_TO_RSTR((*it)));
              }
            }
            return ext_ary;
          }

          static VALUE mime_types()
          {
            VALUE ext_ary = rb_ary_new();
            wxList& hnd_lst = wxImage::GetHandlers();
            for (wxList::compatibility_iterator node = hnd_lst.GetFirst();
                    node; node = node->GetNext())
            {
              wxImageHandler *handler = (wxImageHandler *) node->GetData();
              rb_ary_push(ext_ary, WXSTR_TO_RSTR(handler->GetMimeType()));
            }
            return ext_ary;
          }

          static VALUE handler_extensions()
          {
            VALUE ext_hash = rb_hash_new();
            wxList& hnd_lst = wxImage::GetHandlers();
            for (wxList::compatibility_iterator node = hnd_lst.GetFirst();
                    node; node = node->GetNext())
            {
              wxImageHandler *handler = (wxImageHandler *) node->GetData();
              VALUE ext_ary = rb_ary_new();
              rb_ary_push(ext_ary, WXSTR_TO_RSTR(handler->GetExtension()));
              const wxArrayString& alt_ext = handler->GetAltExtensions();
              for (wxArrayString::const_iterator it = alt_ext.begin(); it!=alt_ext.end() ;++it)
              {
                rb_ary_push(ext_ary, WXSTR_TO_RSTR((*it)));
              }
              wxBitmapType bmp_type = handler->GetType();
              rb_hash_aset(ext_hash, wxRuby_GetEnumValueObject("wxBitmapType", (int)bmp_type), ext_ary);
            }
            return ext_hash;
          }
          __HEREDOC
        # The GetRgbData and GetAlphaData methods require special handling using %extend;
        spec.ignore %w[wxImage::GetData wxImage::GetAlpha]
        # The SetRgbData and SetAlphaData are dealt with by typemaps (see below).
        # For Image#set_rgb_data, Image#set_alpha_data and Image.new/create with raw data arg:
        # copy raw string data from a Ruby string to a memory block that will be
        # managed by wxWidgets (see static_data typemap below)
        spec.map 'unsigned char* data', 'unsigned char* alpha', as: 'String' do
          map_in code: <<~__CODE
            if ( TYPE($input) == T_STRING )
              {
                int data_len = RSTRING_LEN($input);
                $1 = (unsigned char*)malloc(data_len);
                memcpy($1, StringValuePtr($input), data_len);
              }
            else
              SWIG_exception_fail(SWIG_ERROR, 
                                  "String required as raw Image data argument");
            __CODE
          map_typecheck precedence: 'POINTER', code: '$1 = (TYPE($input) == T_STRING);'
        end
        spec.map 'unsigned char* alpha_or_null', as: 'String' do
          map_in code: <<~__CODE
            if ( TYPE($input) == T_STRING )
              {
                int data_len = RSTRING_LEN($input);
                $1 = (unsigned char*)malloc(data_len);
                memcpy($1, StringValuePtr($input), data_len);
              }
            else if ( $input == Qnil ) // Needed for SetAlpha
              $1 = NULL;
            else
              SWIG_exception_fail(SWIG_ERROR, 
                                  "String required as raw Image data argument");
            __CODE
          map_typecheck precedence: 'POINTER', code: '$1 = NIL_P($input) || (TYPE($input) == T_STRING);'
        end
        # Image.new(data...) and Image#set_alpha_data both accept a static_data
        # argument to specify whether wxWidgets should delete the data
        # pointer. Since in wxRuby we always copy from the Ruby string object
        # to the Image, we always want wxWidgets to handle deletion of the copy
        spec.map 'bool static_data' do
          map_in ignore: true, code: '$1 = false;'
        end

        # For get_or_find_mask_colour, which should returns a triplet
        # containing the mask colours, plus its normal Boolean return value.
        spec.map_apply 'unsigned char *OUTPUT' => ['unsigned char* r',
                                                   'unsigned char* g',
                                                   'unsigned char* b' ]
        # GetRgbData and GetAlphaData methods return an unsigned char* pointer to the
        # internal representation of the image's data. We can't simply use
        # rb_str_new2 because the data is not NUL terminated, so strlen won't
        # return the right length; we have to know the image's height and
        # width to give the ruby string the right length.
        #
        # Unlike the C++ version of these methods, these return copies of the
        # data; the ruby string is NOT a pointer to that internal data and
        # cannot be directly manipulated to change the image. This is tricky
        # b/c of Ruby's GC; it might be possible, as in mmap (see
        # http:#blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/296601)
        # but I do not think it is desirable.
        spec.add_extend_code 'wxImage', <<~__HEREDOC
          VALUE get_alpha_data() {
            unsigned char* alpha_data = $self->GetAlpha();
            int length = $self->GetWidth() * $self->GetHeight();
            return rb_str_new( (const char*)alpha_data, length);
          }
        
          VALUE get_rgb_data() {
            unsigned char* rgb_data = $self->GetData();
            int length = $self->GetWidth() * $self->GetHeight() * 3;
            return rb_str_new( (const char*)rgb_data, length);
          }
          __HEREDOC
        # ignore this so we do not have to wrap wxImageHistogram
        spec.ignore 'wxImage::ComputeHistogram'
        # add custom method simply returning Hash; finish off in pure Ruby
        spec.add_extend_code 'wxImage', <<~__HEREDOC
          VALUE compute_histogram()
          {
            VALUE rb_img_hist = rb_hash_new();
            wxImageHistogram img_hist;
            $self->ComputeHistogram(img_hist);
            for (auto pair : img_hist)
            {
              VALUE rb_hist_entry = rb_ary_new();
              rb_ary_push(rb_hist_entry, ULL2NUM(pair.second.index));
              rb_ary_push(rb_hist_entry, ULL2NUM(pair.second.value));
              rb_hash_aset(rb_img_hist, ULL2NUM(pair.first), rb_hist_entry);
            }
            return rb_img_hist;
          }
          __HEREDOC
        # make sure to wrap the public attributes
        spec.regard 'wxImage::HSVValue::hue',
                    'wxImage::HSVValue::saturation',
                    'wxImage::HSVValue::value',
                    'wxImage::RGBValue::red',
                    'wxImage::RGBValue::green',
                    'wxImage::RGBValue::blue'
        # ignore these and add customs
        spec.ignore 'wxImage::HSVtoRGB',
                    'wxImage::RGBtoHSV'
        spec.add_extend_code 'wxImage', <<~__HEREDOC
          static wxImage::RGBValue hsv_to_rgb(VALUE arg)
          {
            std::unique_ptr<wxImage::HSVValue> tmp;
            wxImage::HSVValue* p_hsv;
            if ( TYPE(arg) == T_DATA )
            {
              void* argp;
              SWIG_ConvertPtr(arg, &argp, SWIGTYPE_p_wxImage__HSVValue, 0);
              p_hsv = reinterpret_cast< wxImage::HSVValue * >(argp);
            }
            else if ( TYPE(arg) == T_ARRAY && RARRAY_LEN(arg) == 3 )
            {
              p_hsv = new wxImage::HSVValue( NUM2DBL( rb_ary_entry(arg, 0) ),
                                             NUM2DBL( rb_ary_entry(arg, 1) ),
                                             NUM2DBL( rb_ary_entry(arg, 2) ) );
              tmp.reset(p_hsv); // auto destruct when method scope ends 
            }
            else
            {
              rb_raise(rb_eArgError, "Expected either Array(Float,Float,Float) or Wx::Image::HSVValue for #0");
            }
            return wxImage::HSVtoRGB(*p_hsv);
          }

          static wxImage::HSVValue rgb_to_hsv(VALUE arg)
          {
            std::unique_ptr<wxImage::RGBValue> tmp;
            wxImage::RGBValue* p_rgb;
            if ( TYPE(arg) == T_DATA )
            {
              void* argp;
              SWIG_ConvertPtr(arg, &argp, SWIGTYPE_p_wxImage__RGBValue, 0);
              p_rgb = reinterpret_cast< wxImage::RGBValue * >(argp);
            }
            else if ( TYPE(arg) == T_ARRAY && RARRAY_LEN(arg) == 3 )
            {
              p_rgb = new wxImage::RGBValue( NUM2DBL( rb_ary_entry(arg, 0) ),
                                             NUM2DBL( rb_ary_entry(arg, 1) ),
                                             NUM2DBL( rb_ary_entry(arg, 2) ) );
              tmp.reset(p_rgb); // auto destruct when method scope ends 
            }
            else
            {
              rb_raise(rb_eArgError, "Expected either Array(Float,Float,Float) or Wx::Image::RGBValue for #0");
            }
            return wxImage::RGBtoHSV(*p_rgb);
          }
          __HEREDOC
        spec.do_not_generate(:functions)
      end
    end # class Image

  end # class Director

end # module WXRuby3
