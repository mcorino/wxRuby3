#--------------------------------------------------------------------
# @file    toggle_button.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

require_relative './window'

module WXRuby3

  class Director

    class ToggleButton < Window

      def setup
        spec.include('wx/tglbtn.h')
        super
      end
    end # class ToggleButton

  end # class Director

end # module WXRuby3
