# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

# A data-oriented editable table control.

module Wx
  module GRID

    class Grid

      alias :set_table :assign_table
      alias :table= :assign_table

      wx_each_selected_block = instance_method :each_selected_block
      define_method :each_selected_block do
        if block_given?
          wx_each_selected_block.bind(self).call
        else
          ::Enumerator.new { |y| wx_each_selected_block.bind(self).call { |sb| y << sb } }
        end
      end

      def get_selected_blocks
        each_selected_block.to_a
      end
      alias :selected_blocks :get_selected_blocks

    end

  end
end
