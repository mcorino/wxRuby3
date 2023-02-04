
class Wx::Variant
  include ::Enumerable

  def each
    get_count.times { |i| yield self[i] } if block_given?
  end

  wx_assign = instance_method :assign
  define_method :assign do |v|
    wx_assign.bind(self).call(v)
    self
  end
  alias :<< :assign
end
