#--------------------------------------------------------------------
# @file    splitter_window.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

require_relative './window'

module WXRuby3

  class Director

    class SplitterWindow < Window

      def setup
        spec.rename_for_ruby('Init' => 'wxSplitterWindow::Initialize')
        # this reimplemented window base method need to be properly wrapped but
        # is missing from the XML docs
        spec.extend_interface('wxSplitterWindow', 'virtual void OnInternalIdle()')
        super
      end
    end # class SplitterWindow

  end # class Director

end # module WXRuby3
