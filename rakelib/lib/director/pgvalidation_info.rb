# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class PGValidationInfo < Director

      def setup
        super
        spec.items << 'propgrid/propgrid.h'
        spec.gc_as_untracked 'wxPGValidationInfo'
        if Config.instance.wx_version < '3.3.0'
          spec.ignore 'wxPGVFBFlags' # not a constant but a rather a clumsy typedef
          spec.map 'wxPGVFBFlags' => 'Integer' do
            map_in code: '$1 = (unsigned char)NUM2UINT($input);'
            map_out code: '$result = UINT2NUM((unsigned int)$1);'
          end
        else # from 3.3.0 this is an enum but docs are still missing
        end
      end
    end # class PGValidationInfo

  end # class Director

end # module WXRuby3
