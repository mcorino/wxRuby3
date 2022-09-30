#--------------------------------------------------------------------
# @file    tool_tip.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

module WXRuby3

  class Director

    class TooTip < Director

      def setup
        spec.set_only_for('__WXMSW__', 'wxToolTip::SetMaxWidth')
        super
      end
    end # class TooTip

  end # class Director

end # module WXRuby3
