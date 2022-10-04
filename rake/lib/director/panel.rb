#--------------------------------------------------------------------
# @file    panel.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

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
