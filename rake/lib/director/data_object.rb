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
        spec.items.concat %w[wxDataObjectSimple wxBitmapDataObject]
        spec.gc_as_object
        spec.swig_include '../shared/data_format.i'
        spec.swig_include '../shared/data_object_common.i'
        # ignore the shortened 'convenience' forms
        spec.ignore 'wxDataObjectSimple::GetDataHere(void *) const'
        spec.ignore 'wxDataObjectSimple::SetData(size_t, const void *)'
        spec.ignore 'wxDataObjectSimple::GetDataSize() const'
        # these are missing in the XML doc but fully implemented here
        # add them, so SWIG does not think this is an abstract class
        spec.extend_interface('wxDataObjectSimple',
                              'virtual void GetAllFormats(wxDataFormat *formats, Direction dir=Get) const',
                              'virtual bool GetDataHere(const wxDataFormat &format, void *buf) const',
                              'virtual size_t GetDataSize(const wxDataFormat &format) const',
                              'virtual size_t GetFormatCount(Direction dir=Get) const',
                              'virtual wxDataFormat GetPreferredFormat(Direction dir=Get) const')
        # for these 'final' classes forget about any of the virtual methods since these
        # were fully implemented in the base and should not be overridden in Ruby
        %w[wxBitmapDataObject].each do |kls|
          spec.no_proxy %W[
            #{kls}::GetFormatCount
            #{kls}::GetPreferredFormat
            #{kls}::GetAllFormats
            #{kls}::GetDataHere
            #{kls}::GetDataSize
            #{kls}::SetData
            ]
        end
      end
    end # class DataObject

  end # class Director

end # module WXRuby3
