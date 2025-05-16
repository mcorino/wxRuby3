# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx

  module AUI

    class AuiNotebook

      # Iterate each notebook page.
      # Passes each page to the given block.
      # Returns an Enumerator if no block given.
      # @overload each_page(&block)
      #   @yieldparam [Wx::Window] page notebook page
      #   @return [Object] last result of block
      # @overload each_page()
      #   @return [Enumerator] enumerator
      def each_page(*) end

      # Finds tab control and its tab index associated with a given window.
      # @param [Wx::Window] page the notebook page window
      # @return [Array<Wx::AUI::AuiTabCtrl, Integer>, nil] tab control and index if found else nil
      def find_tab(page) end

    end

  end

end
