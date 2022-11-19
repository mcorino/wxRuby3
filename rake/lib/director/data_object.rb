#--------------------------------------------------------------------
# @file    data_object.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

module WXRuby3

  class Director

    class DataObject < Director

      def setup
        super
        spec.items.concat %w[wxDataObjectSimple wxDataObjectComposite wxBitmapDataObject wxFileDataObject wxTextDataObject wxCustomDataObject wxImageDataObject wxURLDataObject]
        spec.gc_as_object
        spec.swig_include '../shared/data_format.i'
        spec.swig_include '../shared/data_object_common.i'

        # ignore the original method declarattions
        spec.ignore 'wxDataObject::GetDataHere(const wxDataFormat &, void *) const'
        spec.ignore 'wxDataObject::SetData(const wxDataFormat &, size_t, const void *)'
        # and add our own (typemapping specific) altered version
        spec.extend_interface 'wxDataObject',
                              'virtual WXRUBY_DATA_OUT GetDataHere(wxDataFormat const &format, void *buf) const',
                              'virtual WXRUBY_DATA_IN SetData(wxDataFormat const &format, size_t len, void const *buf)'

        # we only allow Ruby derivatives from wxDataObject but not of any of the C++ implemented
        # specializations
        %w[wxDataObjectSimple wxDataObjectComposite wxBitmapDataObject wxFileDataObject wxTextDataObject wxCustomDataObject wxImageDataObject wxURLDataObject].each do |kls|
          spec.no_proxy kls
        end

        # ignore the shortened 'convenience' forms
        spec.ignore 'wxDataObjectSimple::GetDataHere(void *) const'
        spec.ignore 'wxDataObjectSimple::SetData(size_t, const void *)'
        spec.ignore 'wxDataObjectSimple::GetDataSize() const'
        # ignore this as all derivatives have a fixed format
        spec.ignore 'wxDataObjectSimple::SetFormat'

        # ignore these as all fully implemented in derived and not useful in Ruby
        spec.ignore 'wxCustomDataObject::Alloc'
        spec.ignore 'wxCustomDataObject::Free'
        spec.ignore 'wxCustomDataObject::GetData'
        spec.ignore 'wxCustomDataObject::SetData'
        spec.ignore 'wxCustomDataObject::GetSize'
        spec.ignore 'wxCustomDataObject::TakeData'

        # all available in bases
        spec.ignore 'wxTextDataObject::GetFormatCount'
        spec.ignore 'wxTextDataObject::GetFormat'
        spec.ignore 'wxTextDataObject::GetAllFormats'

        %w[wxDataObjectComposite wxBitmapDataObject wxFileDataObject wxTextDataObject wxImageDataObject wxURLDataObject].each do |kls|
          spec.add_swig_code <<~__HEREDOC
            // SWIG gets confused and doesn't realise that various virtual methods
            // from wxDataObject are implemented fully in this subclass, and so,
            // believing it to be abstract doesn't provide an allocator for this
            // class. This undocumented feature overrides this.
            %feature("notabstract") #{kls};
            __HEREDOC
        end

        # Once a DataObject has been added, it belongs to the wxDataObjectComposite object,
        # and will be freed by it on destruction.
        spec.disown 'wxDataObjectSimple* dataObject'
        # Write our own wxDataObjectComposite#get_data_here and wxDataObjectComposite#set_data methods,
        # easier than trying to do typemaps for these as it's a final class
        spec.add_extend_code 'wxDataObjectComposite', <<~__HEREDOC
          VALUE get_data_here(VALUE rb_format)
          {
            VALUE result;
            // Convert the DataFormat object
            void* ptr;
            SWIG_ConvertPtr(rb_format, &ptr, SWIGTYPE_p_wxDataFormat, 0);
            wxDataFormat* format = reinterpret_cast< wxDataFormat * >(ptr);
            
            // Create and read in the buffer
            size_t data_size = $self->GetDataSize(*format);
            char *buf = new char [ data_size ];
            if ( $self->GetDataHere(*format, (void *)buf) )
              result = rb_str_new( (const char*)buf, data_size );
            else
              result = Qnil;
        
            // Tidy up and return
            delete [] buf;
            return result;
          }
        
          VALUE set_data(VALUE rb_format, VALUE data)
          {
            void* ptr;
            SWIG_ConvertPtr(rb_format, &ptr, SWIGTYPE_p_wxDataFormat, 0);
            wxDataFormat* format = reinterpret_cast< wxDataFormat * >(ptr);
        
            if ( $self->SetData(*format,
                                RSTRING_LEN(data),
                                (const void*)StringValuePtr(data) ) )
              return Qtrue;
            else
              return Qfalse;
          }
          __HEREDOC
      end
    end # class DataObject

  end # class Director

end # module WXRuby3
