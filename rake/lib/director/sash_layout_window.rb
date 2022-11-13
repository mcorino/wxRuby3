#--------------------------------------------------------------------
# @file    sash_layout_window.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

module WXRuby3

  class Director

    class SashLayoutWindow < Window

      def setup
        super
        spec.items << 'wxLayoutAlgorithm'
      end

    end # class SashLayoutWindow

  end # class Director

end # module WXRuby3
