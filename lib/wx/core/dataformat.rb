# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# 
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

# Make this easier to use for multi-typed data objects. Comparison
# doesn't work correctly in the SWIG binding

class Wx::DataFormat
  def ==(other)
    if other.is_a?(Wx::DataFormatId)
      self.get_type == other
    elsif other.is_a?(self.class)
      if self.get_type > Wx::DataFormatId::DF_INVALID
        self.get_type == other.get_type
      else
        self.id == other.id
      end
    else
      false
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
  if Wx.has_feature?(:USE_HTML) && Wx.at_least_wxwidgets?('3.3.0')
    DF_HTML        = DataFormat.new( Wx::DataFormatId::DF_HTML )
  end
end
