#--------------------------------------------------------------------
# @file    image.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

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
          'wxImage::GetImageCount(wxInputStream &,wxBitmapType)'
          ]
        spec.rename_for_ruby(
          'LoadStream' => ['wxImage::LoadFile(wxInputStream &,long,int)', 'wxImage::LoadFile(wxInputStream &,const wxString &,int)'],
          'Write' => ['wxImage::SaveFile(wxOutputStream &,int) const', 'wxImage::SaveFile(wxOutputStream &,const wxString &) const'],
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
        # The GetRgbData and GetAlphaData methods require special handling using %extend;
        spec.ignore %w[wxImage::GetData wxImage::GetAlpha]
        # The SetRgbData and SetAlphaData are dealt with by typemaps (see below).
        # For Image#set_rgb_data, Image#set_alpha_data and Image.new with raw data arg:
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
            else if ( $input == Qnil ) // Needed for SetAlpha, an error for SetData
              $1 = NULL;
            else
              SWIG_exception_fail(SWIG_ERROR, 
                                  "String required as raw Image data argument");
            __CODE
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
        spec.do_not_generate(:functions)
      end
    end # class Image

  end # class Director

end # module WXRuby3
