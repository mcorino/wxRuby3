# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# 
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

# Multi-item control with numerous possible view styles

class Wx::ListCtrl
  # Make these ruby enumerables so find, find_all, map are available 
  include Enumerable
  # Passes each valid item index into the passed block
  def each(&block)
    if block_given?
      0.upto(item_count - 1) { | i | block.call(i) }
    else
      ::Enumerator.new { |y| each { | i | y << i } }
    end
  end

  def each_selected(&block)
    if block_given?
      item = -1
      while (item = get_next_item(item, Wx::LIST_NEXT_ALL, Wx::LIST_STATE_SELECTED)) >= 0
        block.call(item)
      end
    else
      ::Enumerator.new { |y| each_selected { | i | y << i } }
    end
  end

  # Returns an Array containing the indexes of the currently selected
  # items 
  def get_selections
    selections = []
    item = get_next_item(-1, Wx::LIST_NEXT_ALL, Wx::LIST_STATE_SELECTED)
    while item >= 0
      selections << item
      item = get_next_item(item, Wx::LIST_NEXT_ALL, Wx::LIST_STATE_SELECTED) 
    end
    selections
  end

end
