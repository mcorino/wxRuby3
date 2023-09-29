# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

class Wx::RBN::RibbonBar

  def pages
    if block_given?
      page_count.times { |i| yield page(i) }
    else
      ::Enumerator.new { |y| page_count.times { |i| y << page(i) } }
    end
  end

end
