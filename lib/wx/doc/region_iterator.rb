
class Wx::RegionIterator

  # Creates a Wx::RegionIterator and passes that to the given block.
  # Removes the iterator after the block finishes.
  # @param [Wx::Region] region
  # @yieldparam [Wx::RegionIterator] region_it
  def self.for_region(region)  end

  # Creates a Wx::RegionIterator and iterates each rectangle in the region executing the given block
  # for each iteration passing the region iterator.
  # @param [Wx::Region] region
  # @yieldparam [Wx::RegionIterator] region_it
  def self.iterate(region) end

  # Returns true if there are rectangles left in the iterated region.
  # @return [Boolean]
  def has_more; end
  alias :has_more? :has_more

  # Moves to the next rectangle of the iterated region.
  # @return [void]
  def next; end

  # If a block is given the given block is called for each rectangle in the region passing the rectangle.
  # If no block is given an Enumerator is returned.
  # @overload each(&block)
  #   @yieldparam [Wx::Rect] rect
  #   @return [Object]
  # @overload each()
  #   @return [Enumerator]
  def each; end

end
