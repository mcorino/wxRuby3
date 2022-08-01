// Copyright 2004-2007, wxRuby development team
// released under the MIT-like wxRuby2 license

// wxRuby includes numerous simple DataObject-derived classes which can
// be used directly without modification: TextDataObject,
// BitmapDataObject etc. The base class DataObject includes lots of pure
// virual methods to be overridden in custom subclasses. In SWIG these
// end up wrapped in directors in subclasses; in the ready-to-go
// DataObject classes, we don't want to call into Ruby, but instead use
// the real C++ working implentations. So lots of ignore/nodirector

// TODO - this probably means at the moment that it's not possible to
// define subclasses of these classes in Ruby.

%ignore GetAllFormats;
%feature("nodirector") GetAllFormats;

%ignore GetDataSize;
%feature("nodirector") GetDataSize;

%ignore GetDataHere;
%feature("nodirector") GetDataHere;

%ignore GetFormatCount;
%feature("nodirector") GetFormatCount;

%ignore GetPreferredFormat;
%feature("nodirector") GetPreferredFormat;

%ignore SetData;
%feature("nodirector") SetData;
