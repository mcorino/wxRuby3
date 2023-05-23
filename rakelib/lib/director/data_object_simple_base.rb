###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class DataObjectSimpleBase < Director

      include Typemap::DataFormat
      include Typemap::DataObjectData

      def setup
        super
        spec.items.clear
        spec.gc_as_object
        spec.initialize_at_end = true

        spec.swig_import 'ext/wxruby3/swig/classes/include/wxDataObject.h'

        spec.add_header_code <<~__HEREDOC
          class wxDataObjectSimpleBase : public wxDataObjectSimple
          {
          public:
            wxDataObjectSimpleBase(const wxDataFormat &format=wxFormatInvalid)
              : wxDataObjectSimple(format) {}
          
            virtual size_t GetDataSize() const { return _GetDataSize(); }
            virtual size_t GetDataSize(const wxDataFormat &) const { return _GetDataSize(); }
            virtual bool GetDataHere(const wxDataFormat &, void *buf) const { return _GetData(buf); }
            virtual bool GetDataHere(void *data_buffer) const { return _GetData(data_buffer); }
            virtual bool SetData(const wxDataFormat &, size_t len, const void *buf) { return _SetData(len, buf); }
            virtual bool SetData(size_t len, const void *buf) { return _SetData(len, buf); }
          
          protected:
            virtual size_t _GetDataSize() const { return 0; }
            virtual bool _GetData(void *data_buffer) const { return false; }
            virtual bool _SetData(size_t len, const void *buf) { return false; }
          };
          __HEREDOC

        spec.add_interface_code <<~__HEREDOC
          class wxDataObjectSimpleBase : public wxDataObjectSimple
          {
          public:
            wxDataObjectSimpleBase(const wxDataFormat &format=wxFormatInvalid);
          
            virtual size_t GetDataSize() const;
            virtual size_t GetDataSize(const wxDataFormat &format) const;
            %feature("numoutputs", "0") GetDataHere;
            virtual VOID_BOOL GetDataHere(const wxDataFormat &format, void *buf) const;
            virtual VOID_BOOL GetDataHere(void *data_buffer) const;
            virtual bool SetData(const wxDataFormat &format, size_t len, const void *buf);
            virtual bool SetData(size_t len, const void *buf);
            virtual void GetAllFormats(wxDataFormat *formats, Direction dir=Get) const;
            virtual size_t GetFormatCount(Direction dir=Get) const;
            virtual wxDataFormat GetPreferredFormat(Direction dir=Get) const;
          
          protected:
            virtual size_t _GetDataSize() const;
            %feature("numoutputs", "0") _GetData;
            virtual VOID_BOOL _GetData(void *data_buffer) const;
            virtual bool _SetData(size_t len, const void *buf);
          };
          __HEREDOC

        # For wxDataObjectSimpleBase::GetDataHere/_GetData : the ruby method should
        # return either a string containing the
        # data, or nil if the data cannot be provided for some reason.
        spec.map 'void *data_buffer' do

          map_in ignore: true, code: ''

          # "misuse" the 'check' typemap to initialize the ignored argument
          # since this is inserted after any non-ignored arguments have been converted we can use these
          # here
          map_check temp: 'std::unique_ptr<char[]> data_buf, size_t data_size', code: <<~__CODE
            data_size = arg1->GetDataSize();
            data_buf = std::make_unique<char[]>(data_size);
            $1 = data_buf.get ();
          __CODE

          # ignore C defined return value entirely (also affects directorout)
          map_out ignore: 'bool'

          map_argout as: {type: 'String', index: 1}, code: <<~__CODE
            if (result)
            {
              $result = rb_str_new( (const char*)data_buf$argnum.get(), data_size$argnum);
            }
            else
              $result = Qnil;
          __CODE

          # ignore the buffer pointer for now
          map_directorin code: ''

          map_directorargout code: <<~__CODE
            if (RTEST(result))
            {
              if (TYPE(result) == T_STRING)
              {
                memcpy(data_buffer, StringValuePtr(result), RSTRING_LEN(result) );
                c_result = true;
              }
              else
              {
                Swig::DirectorTypeMismatchException::raise(rb_eTypeError, 
                                                           "get_data_here should return a string, or nil on failure");
              }
            }
            else
              c_result = false;
          __CODE

        end

        # Once a DataObject has been added, it belongs to the wxDataObjectComposite object,
        # and will be freed by it on destruction.
        # spec.disown 'wxDataObjectSimple* dataObject'
      end
    end # class DataObject

  end # class Director

end # module WXRuby3
