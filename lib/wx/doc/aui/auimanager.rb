# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx

  module AUI

    class AuiManager

      # Yield each pane to the given block.
      # @yieldparam [Wx::AUI::AuiPaneInfo] pane the Aui pane info yielded
      def each_pane; end

      # Returns an array of all panes managed by the frame manager.
      # @return [Array<Wx::AUI::AuiPaneInfo>] all managed panes
      def get_all_panes; end
      alias_method :all_panes, :get_all_panes
    end

  end

end
