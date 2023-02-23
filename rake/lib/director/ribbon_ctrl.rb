###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
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
      end
    end # class RibbonControl

  end # class Director

end # module WXRuby3
