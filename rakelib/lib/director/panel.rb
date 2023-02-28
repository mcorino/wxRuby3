###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './window'

module WXRuby3

  class Director

    class Panel < Window

      def setup
        super
        spec.no_proxy 'wxPanel::Layout'
      end
    end # class Panel

  end # class Director

end # module WXRuby3
