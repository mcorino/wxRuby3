
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
      ::Enumerator.new do |y|
        while has_more?
          y << get_rect
          next
        end
      end
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
