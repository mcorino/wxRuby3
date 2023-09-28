# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# 
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

class Wx::RegionIterator

  alias :have_rects? :have_rects

  # Ruby like enumeration
  def each
    if block_given?
      while have_rects
        yield get_rect
        next_rect
      end
    else
      # The region iterator instance cannot be allowed to exist beyond the outer
      # Wx::RegionIterator.for_region block as it is a temporary instance that
      # will stop to exist when the outer block finishes, so we collect the rectangles
      # here and return an enumerator on that
      arr = []
      while has_rects
        arr << get_rect
        next_rect
      end
      arr.each
    end
  end

  def self.iterate(region, &block)
    return unless block
    for_region(region) do |ri|
      while ri.have_rects
        block.call(ri)
        ri.next_rect
      end
    end
  end

end
