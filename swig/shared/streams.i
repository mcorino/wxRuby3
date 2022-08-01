// Copyright 2004-2008, wxRuby development team
// released under the MIT-like wxRuby2 license

// wxInputStream and wxOutputStream are used to allow certain classes in
// wxWidgets - for example, wxImage - to read and write data from
// arbitrary streams. Rather than expose these classes directly, which
// would duplicate ruby's IO/File classes, wxRuby here provides the
// ability for any IO-like object implementing "read" to act as an input
// stream, and similarly any object implementing "write" to act as an
// output stream.

// So there are two thin classes which translate C++ calls to IO
// functions to the equivalent ruby calls, and, below, tyemaps that
// create these wrapper objects as needed.

%{
// Allows a ruby IO-like object to be treated as a wxInputStream
class wxRubyInputStream : public wxInputStream
  {
  public:
    // Initialize with the readable ruby IO-like object
	wxRubyInputStream(VALUE rb_io) { 
      m_rbio = rb_io; 
      m_lastlength = 0;
    }

	bool CanRead() {
	  return ( ! RTEST( rb_funcall(m_rbio, rb_intern("closed?"), 0) ) );
	}
	char GetC() { 
	  return (char)NUM2INT( rb_funcall(m_rbio, rb_intern("getc"), 0) );
	}
	bool Eof() {
	  return RTEST( rb_funcall(m_rbio, rb_intern("eof"), 0) );
	}
    size_t LastRead() {
      return m_lastlength;
    }
	size_t OnSysRead(void *buffer, size_t bufsize) {
	  VALUE read_data = rb_funcall(m_rbio, rb_intern("read"), 
								   1, INT2NUM(bufsize));
      m_lastlength = RSTRING_LEN(read_data);
	  memcpy(buffer, RSTRING_PTR(read_data), m_lastlength);
	  return m_lastlength;
	}
	wxRubyInputStream& Read(void *buffer, size_t size) {
	  VALUE read_data = rb_funcall(m_rbio, rb_intern("read"), 
								   1, INT2NUM(size));
      m_lastlength = RSTRING_LEN(read_data);
	  memcpy(buffer, RSTRING_PTR(read_data), m_lastlength);
	  return *this;
	}
	off_t SeekI(off_t pos, wxSeekMode mode = wxFromStart) {
	  // Seek mode integers happily coincide in Wx and Ruby
	  rb_funcall( m_rbio, rb_intern("seek"), 2, 
				  INT2NUM(pos), INT2NUM(mode) );
	  return this->TellI();
	}
	off_t TellI() {
	  return NUM2INT( rb_funcall( m_rbio, rb_intern("tell"), 0) );
	}
  protected:
	VALUE m_rbio; // Wrapped ruby object
    int m_lastlength; // Length of last read data
  };

// Allows a ruby IO-like object to be used as a wxOutputStream
class wxRubyOutputStream : public wxOutputStream
  {
  public:
    // Initialize with the writeable ruby IO-like object
	wxRubyOutputStream(VALUE rb_io) { 
      m_rbio = rb_io; 
      m_lastlength = 0;
    }

	bool Close() {
	  rb_funcall(m_rbio, rb_intern("close"), 0); // always returns nil
      return true;
	}
	size_t LastWrite() { 
      return m_lastlength;
	}
	void PutC(char c) {
	  rb_funcall(m_rbio, rb_intern("putc"), 1, INT2NUM(c) );
      return;
	}
	size_t OnSysWrite(const void *buffer, size_t size) {
	  VALUE write_data = rb_str_new((const char *)buffer, size);
      VALUE ret_val = rb_funcall(m_rbio, rb_intern("write"), 1,
                                 write_data);
      m_lastlength = NUM2INT(ret_val);
	  return m_lastlength;
	}
	off_t SeekO(off_t pos, wxSeekMode mode = wxFromStart) {
	  // Seek mode integers happily coincide in Wx and Ruby
	  rb_funcall( m_rbio, rb_intern("seek"), 2, 
				  INT2NUM(pos), INT2NUM(mode) );
	  return this->TellO();
	}
	off_t TellO() {
	  return NUM2INT( rb_funcall( m_rbio, rb_intern("tell"), 0) );
	}
	wxRubyOutputStream& Write(const void *buffer, size_t size) {
	  VALUE write_data = rb_str_new((const char *)buffer, size);
      VALUE ret_val = rb_funcall(m_rbio, rb_intern("write"), 1,
                                 write_data);
      m_lastlength = NUM2INT(ret_val);
	  return *this;
	}

  protected:
	VALUE m_rbio; // Wrapped ruby object
    int m_lastlength; // Length of last write
  };

%}

// Typemaps to create temporary wxStream objects
%typemap(in) wxInputStream& "$1 = new wxRubyInputStream($input);"
%typemap(typecheck, precedence=1) wxInputStream & {
  $1 = ( RTEST(rb_respond_to($input, rb_intern("read") ) ) );
}
%typemap(freearg) wxInputStream& "delete $1;"

%typemap(in) wxOutputStream& "$1 = new wxRubyOutputStream($input);"
%typemap(typecheck, precedence=1) wxOutputStream& {
  $1 = ( RTEST(rb_respond_to($input, rb_intern("write") ) ) );
}
%typemap(freearg) wxOutputStream& "delete $1;"
