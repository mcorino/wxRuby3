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

    class ToolTip < Director

      def setup
        spec.set_only_for('__WXMSW__', 'wxToolTip::SetMaxWidth')
        super
      end
    end # class ToolTip

  end # class Director

end # module WXRuby3
