# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx

  module AUI

    class AuiManager

      # Yield each pane to the given block.
      # If no block passed returns an Enumerator.
      # @yieldparam [Wx::AUI::AuiPaneInfo] pane the Aui pane info yielded
      # @return [::Object, ::Enumerator] result of last block execution or enumerator
      def each_pane; end

      # Returns an array of all panes managed by the frame manager.
      # @return [Array<Wx::AUI::AuiPaneInfo>] all managed panes
      def get_all_panes; end
      alias_method :all_panes, :get_all_panes
    end

  end

end
