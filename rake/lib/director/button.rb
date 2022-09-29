#--------------------------------------------------------------------
# @file    button.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

module WXRuby3

  class Director

    class Button < Director

      def setup
        spec.no_proxy %w[wxButton::SetDefault]
        super
      end
    end # class Button

  end # class Director

end # module WXRuby3
