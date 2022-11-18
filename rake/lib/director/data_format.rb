#--------------------------------------------------------------------
# @file    data_format.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

module WXRuby3

  class Director

    class DataFormat < Director

      def setup
        super
        spec.gc_as_object
        spec.add_swig_code <<~__HEREDOC
          // In wxWidgets system-standard DataFormats are represented by
          // wxDF_XXX constants. These can be passed directly to methods which
          // accept a DataFormat argument through C++ typecasting.
          // 
          // In wxRuby it's hard to do the same thing safely (ie accept strings or
          // integers for DataFormat arguments) b/c with typemaps they have a
          // tendency to leak through the complex system of directors and
          // overridden methods. So DataFormat arguments are strictly typed to
          // require a DataFormat object.
          //
          // However, since normally we want to work with the standard DataFormat
          // objects, rather than the underlying system ids, the Wx::DF_XXX
          // constants are mapped to DataFormat objects (constructed in
          // lib/wx/classes/dataformat.rb) and the constants exposed as
          // Wx::DATA_FORMAT_ID_XXX, below.
          
          %typemap(in) wxDataFormatId "$1 = static_cast<wxDataFormatId>(NUM2INT($input));"
          %typemap(typecheck) wxDataFormatId "$1 = ( TYPE($input) == T_FIXNUM );"
          %typemap(out) wxDataFormatId "$result = INT2NUM($1);"

          %constant const int DATA_FORMAT_ID_INVALID     = wxDF_INVALID;     
          %constant const int DATA_FORMAT_ID_TEXT        = wxDF_TEXT;        
          %constant const int DATA_FORMAT_ID_BITMAP      = wxDF_BITMAP;      
          %constant const int DATA_FORMAT_ID_METAFILE    = wxDF_METAFILE;    
          %constant const int DATA_FORMAT_ID_SYLK        = wxDF_SYLK;        
          %constant const int DATA_FORMAT_ID_DIF         = wxDF_DIF;         
          %constant const int DATA_FORMAT_ID_TIFF        = wxDF_TIFF;        
          %constant const int DATA_FORMAT_ID_OEMTEXT     = wxDF_OEMTEXT;     
          %constant const int DATA_FORMAT_ID_DIB         = wxDF_DIB;         
          %constant const int DATA_FORMAT_ID_PALETTE     = wxDF_PALETTE;     
          %constant const int DATA_FORMAT_ID_PENDATA     = wxDF_PENDATA;     
          %constant const int DATA_FORMAT_ID_RIFF        = wxDF_RIFF;        
          %constant const int DATA_FORMAT_ID_WAVE        = wxDF_WAVE;        
          %constant const int DATA_FORMAT_ID_UNICODETEXT = wxDF_UNICODETEXT; 
          %constant const int DATA_FORMAT_ID_ENHMETAFILE = wxDF_ENHMETAFILE; 
          %constant const int DATA_FORMAT_ID_FILENAME    = wxDF_FILENAME;    
          %constant const int DATA_FORMAT_ID_LOCALE      = wxDF_LOCALE;      
          %constant const int DATA_FORMAT_ID_PRIVATE     = wxDF_PRIVATE;     
          %constant const int DATA_FORMAT_ID_HTML        = wxDF_HTML;        
          %constant const int DATA_FORMAT_ID_MAX         = wxDF_MAX;
          __HEREDOC
        spec.do_not_generate :variables
      end
    end # class DataFormat

  end # class Director

end # module WXRuby3
