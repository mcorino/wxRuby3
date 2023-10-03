# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

# A data-oriented editable table control.

module Wx
  module GRID

    class Grid

      alias :set_table :assign_table
      alias :table= :assign_table

      wx_selected_blocks = instance_method :selected_blocks
      define_method :selected_blocks do
        if block_given?
          wx_selected_blocks.bind(self).call
        else
          ::Enumerator.new { |y| wx_selected_blocks.bind(self).call { |sb| y << sb } }
        end
      end

    end

  end
end
