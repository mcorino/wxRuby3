# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class DataFormat < Director

      def setup
        super
        spec.gc_as_object
        spec.ignore 'wxDataFormat::operator=='
        if Config.platform == :mingw
          # The formal signature for these is NativeFormat; this is required on
          # MSVC as otherwise an impermissible implicit cast is tried, and so
          # doesn't compile
          spec.ignore 'wxDataFormat::GetType', ignore_doc: false
          spec.extend_interface 'wxDataFormat',
                                'typedef unsigned short NativeFormat',
                                'wxDataFormat::NativeFormat GetType() const'
        end
        spec.do_not_generate :variables
      end
    end # class DataFormat

  end # class Director

end # module WXRuby3
