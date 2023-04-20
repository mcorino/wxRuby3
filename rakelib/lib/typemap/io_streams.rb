###
# wxRuby3 Common typemap definitions
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative '../core/mapping'

module WXRuby3

  module Typemap

    # wxInputStream and wxOutputStream are used to allow certain classes in
    # wxWidgets - for example, wxImage - to read and write data from
    # arbitrary streams. Rather than expose these classes directly, which
    # would duplicate ruby's IO/File classes, wxRuby here provides the
    # ability for any IO-like object implementing "read" to act as an input
    # stream, and similarly any object implementing "write" to act as an
    # output stream.

    # So there are two thin classes which translate C++ calls to IO
    # functions to the equivalent ruby calls, and, the typemaps that
    # create these wrapper objects as needed.
    module IOStreams

      include Typemap::Module

      define do

        map 'wxInputStream &' => 'IO,Wx::InputStream' do

          add_header_code <<~__CODE
            WXRUBY_EXPORT bool wxRuby_IsInputStream(VALUE);
            WXRUBY_EXPORT wxInputStream* wxRuby_RubyToInputStream(VALUE);
            WXRUBY_EXPORT VALUE wxRuby_RubyFromInputStream(wxInputStream&);

            class WXRUBY_EXPORT wxRubyInputStream : public wxInputStream
            {
            public:
              // Initialize with the readable ruby IO-like object
              wxRubyInputStream(VALUE rb_io);
              virtual ~wxRubyInputStream();
          
              wxFileOffset GetLength() const wxOVERRIDE;

              bool CanRead() const wxOVERRIDE;  
              bool Eof() const wxOVERRIDE; 
              bool Ok() const { return IsOk(); }
              bool IsOk() const wxOVERRIDE;
              bool IsSeekable() const wxOVERRIDE;

              VALUE GetRubyIO () { return m_rbio; }

            protected:
              size_t OnSysRead(void *buffer, size_t bufsize) wxOVERRIDE; 
              wxFileOffset OnSysSeek(wxFileOffset seek, wxSeekMode mode) wxOVERRIDE;
              wxFileOffset OnSysTell() const wxOVERRIDE;
  
              VALUE m_rbio; // Wrapped ruby object
            };
            __CODE

          map_in temp: 'std::unique_ptr<wxRubyInputStream> tmp_ris',
                 code: <<~__CODE
            if (rb_obj_is_kind_of($input, rb_cIO))
            {
              tmp_ris = std::make_unique<wxRubyInputStream>($input); 
              $1 = tmp_ris.get();
            }
            else
            {
              $1 = wxRuby_RubyToInputStream($input);
              if (!$1)
              {
                rb_raise(rb_eArgError, "Invalid value for %d expected IO or Wx::InputStream", $argnum-1);
              }
            }
          __CODE

          map_directorin code: <<~__CODE
            $input = wxRuby_RubyFromInputStream($1);
            __CODE

          map_typecheck precedence: 1, code: <<~__CODE
            $1 = rb_obj_is_kind_of($input, rb_cIO) || wxRuby_IsInputStream($input);
            __CODE

        end

        map 'wxOutputStream &' => 'IO' do

          add_header_code <<~__CODE
            WXRUBY_EXPORT bool wxRuby_IsOutputStream(VALUE);
            WXRUBY_EXPORT wxOutputStream* wxRuby_RubyToOutputStream(VALUE);
            WXRUBY_EXPORT VALUE wxRuby_RubyFromOutputStream(wxOutputStream&);

            // Allows a ruby IO-like object to be used as a wxOutputStream
            class WXRUBY_EXPORT wxRubyOutputStream : public wxOutputStream
            {
            public:
              // Initialize with the writeable ruby IO-like object
              wxRubyOutputStream(VALUE rb_io);
              virtual ~wxRubyOutputStream(); 
          
              wxFileOffset GetLength() const wxOVERRIDE;
            
              void Sync() wxOVERRIDE;
              bool Close() wxOVERRIDE; 
              bool Ok() const { return IsOk(); }
              bool IsOk() const wxOVERRIDE;
              bool IsSeekable() const wxOVERRIDE;

              VALUE GetRubyIO () { return m_rbio; }
            
            protected:
              size_t OnSysWrite(const void *buffer, size_t size) wxOVERRIDE; 
              wxFileOffset OnSysSeek(wxFileOffset seek, wxSeekMode mode) wxOVERRIDE;
              wxFileOffset OnSysTell() const wxOVERRIDE;

              VALUE m_rbio; // Wrapped ruby object
            };
            __CODE

          map_in temp: 'std::unique_ptr<wxRubyOutputStream> tmp_ros',
                 code: <<~__CODE
            if (rb_obj_is_kind_of($input, rb_cIO))
            {
              tmp_ros = std::make_unique<wxRubyOutputStream>($input); 
              $1 = tmp_ros.get();
            }
            else
            {
              $1 = wxRuby_RubyToOutputStream($input);
              if (!$1)
              {
                rb_raise(rb_eArgError, "Invalid value for %d expected IO or Wx::OutputStream", $argnum-1);
              }
            }
          __CODE

          map_directorin code: <<~__CODE
            $input = wxRuby_RubyFromOutputStream($1);
          __CODE

          map_typecheck precedence: 1, code: <<~__CODE
            $1 = rb_obj_is_kind_of($input, rb_cIO) || wxRuby_IsOutputStream($input);
            __CODE

        end

      end # define

    end # Streams

  end # Typemap

end # WXRuby3
