# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class FSFile < Director

      include Typemap::IOStreams
      include Typemap::DateTime

      def setup
        super
        spec.items << 'wxStreamBase' << 'wxInputStream' << 'wxOutputStream'
        spec.make_abstract 'wxStreamBase'
        spec.make_abstract 'wxInputStream'
        spec.make_abstract 'wxOutputStream'
        spec.no_proxy 'wxStreamBase', 'wxInputStream', 'wxOutputStream'
        # for FSFile ctor
        spec.map 'wxInputStream *stream' => 'IO' do
          map_in code: <<~__CODE
            if (wxRuby_IsCompatibleInput($input))
            {
              $1 = new wxRubyInputStream($input);
            }
            else
            {
              rb_raise(rb_eArgError, "Invalid value for %d expected IO-like", $argnum-1);
            }
          __CODE
        end
        spec.map 'wxFileOffset' => 'Integer' do
          # we need these inline methods here as we do not want SWIG to preprocess the code
          # as it will do in the type mapping code sections
          add_header_code <<~__CODE
            inline wxFileOffset __ruby2wxFileOffset(VALUE num)
            {
            #ifdef wxHAS_HUGE_FILES
              return static_cast<wxFileOffset> (NUM2LL(num));
            #else
              return static_cast<wxFileOffset> (NUM2LONG(num));
            #endif
            } 
            inline VALUE __wxFileOffset2ruby(wxFileOffset offs)
            {
            #ifdef wxHAS_HUGE_FILES
              return LL2NUM(offs);
            #else
              return LONG2NUM(offs);
            #endif
            } 
            __CODE

          map_in code: '$1 = __ruby2wxFileOffset($input);'
          map_out code: '$result = __wxFileOffset2ruby($1);'
          map_typecheck code: '$1 = TYPE($input) == T_FIXNUM;'
        end
        spec.new_object 'wxFSFile::DetachStream'
        # ignore troublesome methods
        spec.ignore 'wxInputStream::Read(void *, size_t)',
                    'wxInputStream::ReadAll',
                    'wxInputStream::Ungetch(const void *, size_t)'
        # replace with these (except Ungetch)
        spec.add_extend_code 'wxInputStream', <<~__HEREDOC
          VALUE Read(size_t size)
          {
            std::unique_ptr<char[]> buffer = std::make_unique<char[]>(size);
            $self->Read(buffer.get(), size);
            size_t nread = $self->LastRead();
            return nread>0 ? rb_str_new(buffer.get(), nread) : Qnil;
          }
          VALUE ReadAll(size_t size)
          {
            std::unique_ptr<char[]> buffer = std::make_unique<char[]>(size);
            size_t nread = size;
            if (!$self->ReadAll(buffer.get(), size))
            {
              nread = $self->LastRead();
            }
            return nread>0 ? rb_str_new(buffer.get(), nread) : Qnil;
          }
          __HEREDOC
        # for Read(wxOutputStream&)
        spec.map 'wxInputStream&' => 'Wx::InputStream' do
          map_out code: '$result = self; wxUnusedVar($1);'
        end
        # ignore troublesome methods
        spec.ignore 'wxOutputStream::Write',
                    'wxOutputStream::WriteAll'
        # replace with these
        spec.add_extend_code 'wxOutputStream', <<~__HEREDOC
          size_t Write(VALUE input)
          {
            if (TYPE(input) == T_STRING)
            {
              size_t size = RSTRING_LEN(input);
              void* buffer = RSTRING_PTR(input);
              $self->Write(buffer, size);
            }
            else if (rb_obj_is_kind_of(input, rb_cIO) || wxRuby_IsInputStream(input))
            {
              std::unique_ptr<wxInputStream> safe_ris = std::make_unique<wxRubyInputStream>(input);
              $self->Write(*safe_ris.get());
            }
            else
            {
              rb_raise(rb_eArgError, "Invalid value for 0; expected String or IO or Wx::InputStream");
              return 0;
            }
            return $self->LastWrite();
          }
          size_t WriteAll(VALUE input)
          {
            if (TYPE(input) == T_STRING)
            {
              size_t size = RSTRING_LEN(input);
              void* buffer = RSTRING_PTR(input);
              if ($self->WriteAll(buffer, size))
              {
                return size;
              }
              return $self->LastWrite();
            }
            rb_raise(rb_eArgError, "Invalid value for 0; expected String");
            return 0;
          }
          __HEREDOC
        # for Write(wxInputStream&)
        spec.map 'wxOutputStream&' => 'Wx::OutputStream' do
          map_out code: '$result = self; wxUnusedVar($1);'
        end
        # type mappings for ctor and DetachStream/GetStream
        spec.add_wrapper_code <<~__CODE
          static WxRuby_ID ios_closed_id("closed?");
          static WxRuby_ID ios_eof_id("eof");
          static WxRuby_ID ios_read_id("read");
          static WxRuby_ID ios_write_id("write");
          static WxRuby_ID ios_seek_id("seek");
          static WxRuby_ID ios_tell_id("tell");
          static WxRuby_ID ios_flush_id("flush");
          static WxRuby_ID ios_close_id("close");

          // Mapping of wxStreamBase* to Ruby IO VALUE
          WX_DECLARE_VOIDPTR_HASH_MAP(VALUE,
                                      WXRBStreamBaseToRbValueHash);
          static WXRBStreamBaseToRbValueHash Stream_Value_Map;

          static void wxRuby_markRbStreams()
          {
            WXRBStreamBaseToRbValueHash::iterator it;
            for( it = Stream_Value_Map.begin(); it != Stream_Value_Map.end(); ++it )
            {
              VALUE obj = it->second;
              rb_gc_mark(obj);
            }
          }

          static void wxRuby_RegisterStream(void* ptr, VALUE rbval)
          {
            Stream_Value_Map[ptr] = rbval;
          }

          static void wxRuby_UnregisterStream(void* ptr)
          {
            Stream_Value_Map.erase(ptr);
          }

          // Implementation for wxRubyInputStream
          // Allows a ruby IO-like object to be treated as a wxInputStream
          wxRubyInputStream::wxRubyInputStream(VALUE rb_io) 
            : wxInputStream()
          { 
            m_rbio = rb_io; 
            m_isIO = rb_obj_is_kind_of(m_rbio, rb_cIO);
            m_isSeekable = m_isIO || (rb_respond_to(m_rbio, ios_seek_id()) && rb_respond_to(m_rbio, ios_tell_id()));
            wxRuby_RegisterStream(this, m_rbio);
          }
          wxRubyInputStream::~wxRubyInputStream() 
          {
            wxRuby_UnregisterStream(this);
          }
        
          wxFileOffset wxRubyInputStream::GetLength() const
          {
            if (!m_isSeekable) return wxInvalidOffset;

            wxFileOffset curpos = this->OnSysTell();
            wxFileOffset endpos = const_cast<wxRubyInputStream*> (this)->OnSysSeek(0, wxFromEnd);
            const_cast<wxRubyInputStream*> (this)->OnSysSeek(curpos, wxFromStart);
            return endpos;
          }

          bool wxRubyInputStream::CanRead() const 
          {
            return !( (m_isIO && RTEST(wxRuby_Funcall(m_rbio, ios_closed_id(),0))) || Eof() );
          }
          bool wxRubyInputStream::Eof() const 
          {
            return m_isIO ? RTEST(wxRuby_Funcall(m_rbio, ios_eof_id(), 0)) : wxInputStream::Eof();
          }
          bool wxRubyInputStream::IsSeekable() const { return m_isSeekable; }
          bool wxRubyInputStream::IsOk() const
          {
            return wxInputStream::IsOk() && !(m_isIO && RTEST(wxRuby_Funcall(m_rbio, ios_closed_id(),0)));
          }
          size_t wxRubyInputStream::OnSysRead(void *buffer, size_t bufsize) 
          {
            VALUE read_data = wxRuby_Funcall(m_rbio, ios_read_id(), 
                                             1, INT2NUM(bufsize));
            if (NIL_P(read_data))
            {
              m_lasterror = wxSTREAM_EOF;
              return 0;
            }
            memcpy(buffer, RSTRING_PTR(read_data), RSTRING_LEN(read_data));
            return RSTRING_LEN(read_data);
          }
          wxFileOffset wxRubyInputStream::OnSysSeek(wxFileOffset seek, wxSeekMode mode)
          {
            if (!m_isSeekable) return wxInvalidOffset;
            
            // Seek mode integers happily coincide in Wx and Ruby
            wxRuby_Funcall(m_rbio, ios_seek_id(), 2, 
                           INT2NUM(seek), INT2NUM(mode));
            return this->OnSysTell();
          }
          wxFileOffset wxRubyInputStream::OnSysTell() const
          {
            if (!m_isSeekable) return wxInvalidOffset;

            return NUM2INT(wxRuby_Funcall(m_rbio, ios_tell_id(), 0));
          }

          // Implementation for wxRubyOutputStream
          // Allows a ruby IO-like object to be used as a wxOutputStream
          wxRubyOutputStream::wxRubyOutputStream(VALUE rb_io)
            : wxOutputStream() 
          { 
            m_rbio = rb_io; 
            m_isIO = rb_obj_is_kind_of(m_rbio, rb_cIO);
            m_isSeekable = m_isIO || (rb_respond_to(m_rbio, ios_seek_id()) && rb_respond_to(m_rbio, ios_tell_id()));
            wxRuby_RegisterStream(this, m_rbio);
          }
          wxRubyOutputStream::~wxRubyOutputStream() 
          {
            wxRuby_UnregisterStream(this);
          }
        
          wxFileOffset wxRubyOutputStream::GetLength() const
          {
            if (!m_isSeekable) return wxInvalidOffset;

            wxFileOffset curpos = this->OnSysTell();
            wxFileOffset endpos = const_cast<wxRubyOutputStream*> (this)->OnSysSeek(0, wxFromEnd);
            const_cast<wxRubyOutputStream*> (this)->OnSysSeek(curpos, wxFromStart);
            return endpos;
          }

          void wxRubyOutputStream::Sync()
          {
            wxOutputStream::Sync();
            if (m_isIO) wxRuby_Funcall(m_rbio, ios_flush_id(), 0);
          }
          bool wxRubyOutputStream::Close() 
          {
            if (m_isIO) wxRuby_Funcall(m_rbio, ios_close_id(), 0); // always returns nil
            return true;
          }
          bool wxRubyOutputStream::IsSeekable() const { return m_isSeekable; }
          bool wxRubyOutputStream::IsOk() const
          {
            return wxOutputStream::IsOk() && !(m_isIO && RTEST(wxRuby_Funcall(m_rbio, ios_closed_id(),0)));
          }

          size_t wxRubyOutputStream::OnSysWrite(const void *buffer, size_t size) 
          {
            VALUE write_data = rb_str_new((const char *)buffer, size);
            VALUE ret_val = wxRuby_Funcall(m_rbio, ios_write_id(), 
                                           1, write_data);
            return NUM2INT(ret_val);
          }
          wxFileOffset wxRubyOutputStream::OnSysSeek(wxFileOffset seek, wxSeekMode mode)
          {
            if (!m_isSeekable) return wxInvalidOffset;
            
            // Seek mode integers happily coincide in Wx and Ruby
            wxRuby_Funcall(m_rbio, ios_seek_id(), 2, 
                           INT2NUM(seek), INT2NUM(mode));
            return this->OnSysTell();
          }
          wxFileOffset wxRubyOutputStream::OnSysTell() const
          {
            if (!m_isSeekable) return wxInvalidOffset;
            
            return NUM2INT(wxRuby_Funcall(m_rbio, ios_tell_id(), 0));
          }

          WXRUBY_EXPORT bool wxRuby_IsInputStream(VALUE rbis)
          {
            swig_class *sklass = (swig_class *)SWIGTYPE_p_wxInputStream->clientdata;
            return (TYPE(rbis) == T_DATA && rb_obj_is_kind_of(rbis, sklass->klass));
          }

          WXRUBY_EXPORT bool wxRuby_IsCompatibleInput(VALUE rbis)
          {
            return rb_obj_is_kind_of(rbis, rb_cIO) || 
              (!wxRuby_IsInputStream(rbis) && rb_respond_to(rbis, ios_read_id()));
          }
          
          WXRUBY_EXPORT wxInputStream* wxRuby_RubyToInputStream(VALUE rbis)
          {
            if (wxRuby_IsInputStream(rbis))
            {
              void *ptr;
              Data_Get_Struct(rbis, void, ptr);
              return static_cast<wxInputStream*>(ptr);
            }
            return 0;
          }

          WXRUBY_EXPORT VALUE wxRuby_RubyFromInputStream(wxInputStream& is)
          {
            wxRubyInputStream* ris = dynamic_cast<wxRubyInputStream*> (&is);
            if (ris)
            {
              return ris->GetRubyIO();
            }
            else
            {
              return SWIG_Ruby_NewPointerObj(&is, SWIGTYPE_p_wxInputStream, 0);
            }
          }

          WXRUBY_EXPORT bool wxRuby_IsOutputStream(VALUE rbos)
          {
            swig_class *sklass = (swig_class *)SWIGTYPE_p_wxOutputStream->clientdata;
            return (TYPE(rbos) == T_DATA && rb_obj_is_kind_of(rbos, sklass->klass));
          }

          WXRUBY_EXPORT bool wxRuby_IsCompatibleOutput(VALUE rbos)
          {
            return rb_obj_is_kind_of(rbos, rb_cIO) || 
              (!wxRuby_IsOutputStream(rbos) && rb_respond_to(rbos, ios_write_id()));
          }
          
          WXRUBY_EXPORT wxOutputStream* wxRuby_RubyToOutputStream(VALUE rbos)
          {
            if (wxRuby_IsOutputStream(rbos))
            {
              void *ptr;
              Data_Get_Struct(rbos, void, ptr);
              return static_cast<wxOutputStream*>(ptr);
            }
            return 0;
          }

          WXRUBY_EXPORT VALUE wxRuby_RubyFromOutputStream(wxOutputStream& os)
          {
            wxRubyOutputStream* ros = dynamic_cast<wxRubyOutputStream*> (&os);
            if (ros)
            {
              return ros->GetRubyIO();
            }
            else
            {
              return SWIG_Ruby_NewPointerObj(&os, SWIGTYPE_p_wxOutputStream, 0);
            }
          }
          __CODE
        spec.add_init_code 'wxRuby_AppendMarker(wxRuby_markRbStreams);'
      end

      def process(gendoc: false)
        defmod = super
        # wxSeekMode is documented in a separate module with a lot of defs we do not want
        # so let's manually insert it's definition here
        seek_mode_enum = Extractor::EnumDef.new(name: 'wxSeekMode',
                                                brief_doc: 'Parameter indicating how file offset should be interpreted.')
        seek_mode_enum.items << Extractor::EnumValueDef.new(enum: seek_mode_enum, name: 'wxFromStart', brief_doc: 'Seek from the file beginning.')
        seek_mode_enum.items << Extractor::EnumValueDef.new(enum: seek_mode_enum, name: 'wxFromCurrent', brief_doc: 'Seek from the current position.')
        seek_mode_enum.items << Extractor::EnumValueDef.new(enum: seek_mode_enum, name: 'wxFromEnd', brief_doc: 'Seek from end of the file.')
        defmod.items << seek_mode_enum
        # same for this
        stream_error_enum = Extractor::EnumDef.new(name: 'wxStreamError',
                                                brief_doc: 'IO stream error codes.')
        stream_error_enum.items << Extractor::EnumValueDef.new(enum: stream_error_enum, name: 'wxSTREAM_NO_ERROR', brief_doc: 'No error occurred.')
        stream_error_enum.items << Extractor::EnumValueDef.new(enum: stream_error_enum, name: 'wxSTREAM_EOF', brief_doc: 'EOF reached.')
        stream_error_enum.items << Extractor::EnumValueDef.new(enum: stream_error_enum, name: 'wxSTREAM_WRITE_ERROR', brief_doc: 'generic write error on the last write call.')
        stream_error_enum.items << Extractor::EnumValueDef.new(enum: stream_error_enum, name: 'wxSTREAM_READ_ERROR', brief_doc: 'generic read error on the last read call.')
        defmod.items << stream_error_enum
        defmod
      end

    end # class FSFile

  end # class Director

end # module WXRuby3
