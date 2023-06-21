# Make this easier to use for multi-typed data objects. Comparison
# doesn't work correctly in the SWIG binding
class Wx::DataFormat
  def ==(other)
    if self.get_type > Wx::DataFormatId::DF_INVALID
      self.get_type == other.get_type
    else
      self.id == other.id
    end
  end
end

# Provide pre-cooked data formats for the standard types
module Wx
  DF_TEXT        = DataFormat.new( Wx::DataFormatId::DF_TEXT )
  DF_BITMAP      = DataFormat.new( Wx::DataFormatId::DF_BITMAP )
  if Wx::PLATFORM != 'WXGTK'
    DF_METAFILE    = DataFormat.new( Wx::DataFormatId::DF_METAFILE )
  end
  if Wx::PLATFORM == 'WXMSW'
    DF_DIB         = DataFormat.new( Wx::DataFormatId::DF_DIB )
  end
  DF_FILENAME    = DataFormat.new( Wx::DataFormatId::DF_FILENAME )
  DF_UNICODETEXT = DataFormat.new( Wx::DataFormatId::DF_UNICODETEXT )
  if Wx.has_feature?(:USE_HTML) && Wx::WXWIDGETS_VERSION >= '3.3'
    DF_HTML        = DataFormat.new( Wx::DataFormatId::DF_HTML )
  end
end
