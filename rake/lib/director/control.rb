#--------------------------------------------------------------------
# @file    control.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

module WXRuby3

  class Director

    class Control < Window

      def setup
        super
        spec.ignore 'wxControl::GetLabelText(const wxString &)'
      end
    end # class Control

  end # class Director

end # module WXRuby3
