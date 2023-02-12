
require 'date'

class Wx::Variant
  include ::Enumerable

  # add a proper enumerator method
  def each
    if block_given?
      get_count.times { |i| yield self[i] }
    else
      ::Enumerator.new { |y| get_count.times { |i| y << self[i] } }
    end
  end

  # add 'smart' conversion for ==
  wx__eq__ = instance_method :==
  define_method :== do |val|
    val = Wx::Variant.new(val) unless Wx::Variant === val
    wx__eq__.bind(self).call(val)
  end

  # make assign return self and add it's handy alias
  wx_assign = instance_method :assign
  define_method :assign do |v|
    wx_assign.bind(self).call(v)
    self
  end
  alias :<< :assign

  # extend to_s to arraylist and list (easier in pure Ruby)

  wx_to_s = instance_method :to_s
  define_method :to_s do
    unless null?
      case type
      when 'list'
        return "[#{each.collect { |v| v.string? ? %Q{"#{v.to_s}"} : v.to_s }.join(', ')}]"
      when 'arrstring'
        return array_string.to_s
      when 'wxFont'
        return font.to_s
      when 'wxColour'
        return colour.to_s
      when 'wxColourPropertyValue'
        return colour_property_value.to_s
      end
    end
    wx_to_s.bind(self).call
  end

  # extend with more Ruby-like type checking

  def string?; !null? && is_type('string'); end
  def bool?; !null? && is_type('bool'); end
  def long?; !null? && is_type('long'); end
  def long_long?; !null? && is_type('longlong'); end
  def u_long_long?; !null? && is_type('ulonglong'); end
  def date_time?; !null? && is_type('datetime'); end
  def double?; !null? && is_type('double'); end
  def list?; !null? && is_type('list'); end
  def array_string?; !null? && is_type('arrstring'); end
  def font?; !null? && is_type('wxFont'); end
  def colour?; !null? && is_type('wxColour'); end
  def colour_property_value?; !null? && is_type('wxColourPropertyValue'); end
  def object?(klass=Object) !null? && is_type('WXRB_VALUE') && klass === object; end
end
