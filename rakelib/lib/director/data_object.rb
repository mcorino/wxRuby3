###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class DataObject < Director

      include Typemap::DataFormat
      include Typemap::DataObjectData

      def setup
        super
        spec.items.concat %w[wxDataObjectSimple wxDataObjectComposite wxBitmapDataObject wxFileDataObject wxTextDataObject wxCustomDataObject wxImageDataObject wxURLDataObject]
        spec.gc_as_object

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
      end
    end # class DataObject

    def doc_generator
      DataObjectDocGenerator.new(self)
    end

  end # class Director

  class DataObjectDocGenerator < DocGenerator

    protected def get_class_doc(clsdef)
      if clsdef.name == 'wxDataObjectSimple'
        []
      else
        super
      end
    end

  end

end # module WXRuby3
