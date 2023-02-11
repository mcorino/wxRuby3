
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

  # protect some tricky methods against segfaulting (not easily done with SWIG)

  def has_value_of?(klass, elem_klass = nil)
    case
    when klass == ::TrueClass ||  klass == ::FalseClass
      is_type('bool')
    when klass == ::String
      is_type('string')
    when klass == ::Time || klass == ::Date || klass == ::DateTime
      is_type('datetime')
    when klass == ::Float
      is_type('double')
    when klass >= ::Numeric
      is_type('long') || is_type('longlong') || is_type('ulonglong')
    when klass == ::Array
      if elem_klass == ::String
        is_type('arrstring')
      elsif elem_klass == Wx::Variant
        is_type('list')
      else
        is_type('WXRB_VALUE') && ::Array === self.object
      end
    when klass == Wx::Font
      is_type('wxFont')
    when klass == Wx::PG::ColourPropertyValue
      is_type('wxColourPropertyValue')
    when klass == Wx::Colour
      is_type('wxColour')
    else
      is_type('WXRB_VALUE') && klass === self.object
    end
  end
  alias :value_of? :has_value_of?
end
