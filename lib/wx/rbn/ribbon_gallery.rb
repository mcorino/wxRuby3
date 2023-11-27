# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

class Wx::RBN::RibbonGallery

  def items
    if block_given?
      count.times { |i| yield item(i) }
    else
      ::Enumerator.new { |y| count.times { |i| y << item(i) } }
    end
  end

end
