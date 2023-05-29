
class Wx::RegionIterator

  alias :has_more? :has_more

  # Ruby like enumeration
  def each
    if block_given?
      while has_more?
        yield get_rect
        next
      end
    else
      # The region iterator instance cannot be allowed to exist beyond the outer
      # Wx::RegionIterator.for_region block as it is a temporary instance that
      # will stop to exist when the outer block finishes, so we collect the rectangles
      # here and return an enumerator on that
      arr = []
      while has_more?
        arr << get_rect
        next
      end
      arr.each
    end
  end

  def self.iterate(region, &block)
    return unless block
    for_region(region) do |ri|
      while ri.has_more?
        block.call(ri)
        ri.next
      end
    end
  end

end
