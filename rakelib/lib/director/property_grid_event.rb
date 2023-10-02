# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './event'

module WXRuby3

  class Director

    include Typemap::PGProperty

    class PropertyGridEvent < Event

      def setup
        super
        if Config.instance.wx_version < '3.3.0'
          spec.map 'wxPGVFBFlags' => 'Integer' do
            map_in code: '$1 = (unsigned char)NUM2UINT($input);'
            map_out code: '$result = UINT2NUM((unsigned int)$1);'
          end
        else # from 3.3.0 this is an enum but docs are still missing
        end
      end
    end # class PropertyGridEvent

  end # class Director

end # module WXRuby3
