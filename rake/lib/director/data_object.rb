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
        spec.items.concat %w[wxDataObjectSimple wxBitmapDataObject wxFileDataObject wxTextDataObject wxCustomDataObject wxImageDataObject wxURLDataObject]
        spec.gc_as_object
        spec.swig_include '../shared/data_format.i'
        spec.swig_include '../shared/data_object_common.i'

        # we only allow Ruby derivatives from wxDataObject but not of any of the C++ implemented
        # specializations
        %w[wxDataObjectSimple wxBitmapDataObject wxFileDataObject wxTextDataObject wxCustomDataObject wxImageDataObject wxURLDataObject].each do |kls|
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

        %w[wxBitmapDataObject wxFileDataObject wxTextDataObject wxImageDataObject wxURLDataObject].each do |kls|
          spec.add_swig_code <<~__HEREDOC
            // SWIG gets confused and doesn't realise that various virtual methods
            // from wxDataObject are implemented fully in this subclass, and so,
            // believing it to be abstract doesn't provide an allocator for this
            // class. This undocumented feature overrides this.
            %feature("notabstract") #{kls};
            __HEREDOC
        end
      end
    end # class DataObject

  end # class Director

end # module WXRuby3
