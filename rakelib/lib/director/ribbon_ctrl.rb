# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './window'

module WXRuby3

  class Director

    class RibbonControl < Window

      def setup
        super
        # type mapping for GetArtProvider return ref
        spec.map 'wxRibbonArtProvider*' => 'Wx::RBN::RibbonArtProvider' do
          add_header_code 'extern VALUE wxRuby_WrapWxRibbonArtProviderInRuby(const wxRibbonArtProvider *wx_rap, int own);'
          # wrap (do not own)
          map_out code: '$result = wxRuby_WrapWxRibbonArtProviderInRuby($1, 0);'
        end
        spec.suppress_warning(473, 'wxRibbonControl::GetAncestorRibbonBar')
      end
    end # class RibbonControl

  end # class Director

end # module WXRuby3
