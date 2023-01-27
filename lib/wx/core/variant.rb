
class Wx::Variant
  include ::Enumerable

  def each
    get_count.times { |i| yield self[i] } if block_given?
  end
end
