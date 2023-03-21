###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class DataFormat < Director

      def setup
        super
        spec.gc_as_object
        spec.ignore 'wxDataFormat::operator ==(wxDataFormatId)'
        if Config.platform == :mingw
          # The formal signature for these is NativeFormat; this is required on
          # MSVC as otherwise an impermissible implicit cast is tried, and so
          # doesn't compile
          spec.ignore 'wxDataFormat::GetType'
          spec.extend_interface 'wxDataFormat',
                                'typedef unsigned short NativeFormat',
                                'wxDataFormat::NativeFormat GetType() const'
        end
        spec.do_not_generate :variables
      end
    end # class DataFormat

  end # class Director

end # module WXRuby3
