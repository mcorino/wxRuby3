#--------------------------------------------------------------------
# @file    splitter_window.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

module WXRuby3

  class Director

    class SplitterWindow < Window

      def setup
        spec.rename_for_ruby('Init' => 'wxSplitterWindow::Initialize')
        super
      end
    end # class SplitterWindow

  end # class Director

end # module WXRuby3
