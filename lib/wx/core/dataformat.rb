# Make this easier to use for multi-typed data objects. Comparison
# doesn't work correctly in the SWIG binding
class Wx::DataFormat
  def ==(other)
    if self.get_type > Wx::DATA_FORMAT_ID_INVALID
      self.get_type == other.get_type
    else
      self.id == other.id
    end
  end
end

# Provide pre-cooked data formats for the standard types
module Wx
  DF_TEXT        = DataFormat.new( DATA_FORMAT_ID_TEXT )
  DF_BITMAP      = DataFormat.new( DATA_FORMAT_ID_BITMAP )
  if Wx::PLATFORM != 'WXGTK'
    DF_METAFILE    = DataFormat.new( DATA_FORMAT_ID_METAFILE )
  end
  DF_FILENAME    = DataFormat.new( DATA_FORMAT_ID_FILENAME )
  DF_UNICODETEXT = DataFormat.new( DATA_FORMAT_ID_UNICODETEXT )
  # DF_HTML is only supported on Windows + MSVC, so don't offer it
end
