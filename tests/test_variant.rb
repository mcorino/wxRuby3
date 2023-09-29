# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

require_relative './lib/wxapp_runner'

class TestVariant < Test::Unit::TestCase

  def test_basics
    var = Wx::Variant.new('text variant')
    assert_equal('text variant', var.get_string)
    var = Wx::Variant.new(true)
    assert_equal(true, var.get_bool)
    var = Wx::Variant.new(1234)
    assert_equal(1234, var.get_long)
    assert_equal(1234, var.to_i)
    var = Wx::Variant.new(1234.5678)
    assert_equal(1234.5678, var.get_double)
    var = Wx::Variant.new(2**64-1)
    assert_equal(2**64-1, var.get_u_long_long)
    assert_equal(2**64-1, var.to_i)
    var = Wx::Variant.new(1-(2**63))
    assert_equal(1-(2**63), var.get_long_long)
    assert_equal(1-(2**63), var.to_i)
    tm = Time.now
    var = Wx::Variant.new(tm)
    assert_equal(tm.round(3), var.get_date_time)
    assert_equal(tm.round(3).to_i, var.to_i)
    var = Wx::Variant.new(%w[one two three four])
    assert_equal(%w[one two three four], var.get_array_string)
    vars = ['one', 2, true].collect { |o| Wx::Variant.new(o) }
    var = Wx::Variant.new(vars)
    assert(var.all? { |v| v == vars.shift })
  end

  class AClass
    def initialize(o)
      @val = o
    end

    def ==(other)
      self.class === other && @val == other.instance_variable_get('@val')
    end
  end

  def test_ruby_values
    var = Wx::Variant.new({one: 1, two: 2, three: 3})
    GC.start
    assert_equal({one: 1, two: 2, three: 3}, var.get_object)
    GC.start
    var = Wx::Variant.new(AClass.new([1,2,3,4]))
    GC.start
    assert_equal(AClass.new([1,2,3,4]), var.get_object)
    GC.start
  end

  def test_wx_objects
    font = Wx::Font.new(10, Wx::FONTFAMILY_SWISS, Wx::FONTSTYLE_NORMAL, Wx::FONTWEIGHT_NORMAL)
    var = Wx::Variant.new(font)
    GC.start
    assert_equal(font, var.font)
    assert_equal(Wx::Font, var.font.class)
    img = Wx::Image.new
    var = Wx::Variant.new(img)
    GC.start
    assert_equal(img, var.object)
    assert_equal(Wx::Image, var.object.class)
    col = Wx::Colour.new('RED')
    var = Wx::Variant.new(col)
    GC.start
    assert_equal(col, var.colour)
    col = Wx::Colour.new(246, 22, 22)
    var = Wx::Variant.new(col)
    GC.start
    assert_equal(col, var.colour)
  end

  def test_assign
    var = Wx::Variant.new('text variant')
    assert_equal('text variant', var.get_string)
    var.assign(true)
    assert_equal(true, var.get_bool)
    var.assign(1234)
    assert_equal(1234, var.get_long)
    var.assign(1234.5678)
    assert_equal(1234.5678, var.get_double)
    var.assign(2**64-1)
    assert_equal(2**64-1, var.get_u_long_long)
    var.assign(1-(2**63))
    assert_equal(1-(2**63), var.get_long_long)
    tm = Time.now
    var.assign(tm)
    assert_equal(tm.round(3), var.get_date_time)
    var.assign(%w[one two three four])
    assert_equal(%w[one two three four], var.get_array_string)
    vars = ['one', 2, true].collect { |o| Wx::Variant.new(o) }
    var.assign(vars)
    assert(var.all? { |v| v == vars.shift })
    var << AClass.new([1,2,3,4])
    assert_equal(AClass.new([1,2,3,4]), var.get_object)
  end

  def test_to_s
    var = Wx::Variant.new('text variant')
    assert_equal('text variant', var.to_s)
    var = Wx::Variant.new(true)
    assert_equal(true.to_s, var.to_s)
    var = Wx::Variant.new(1234)
    assert_equal((1234).to_s, var.to_s)
    var = Wx::Variant.new(1234.5678)
    assert_equal((1234.5678).to_s, var.to_s)
    var = Wx::Variant.new(2**64-1)
    assert_equal((2**64-1).to_s, var.to_s)
    var = Wx::Variant.new(1-(2**63))
    assert_equal((1-(2**63)).to_s, var.to_s)
    tm = Time.now
    var = Wx::Variant.new(tm)
    assert_equal(tm.round(3).to_s, var.to_s)
    var = Wx::Variant.new(%w[one two three four])
    assert_equal(%w[one two three four].to_s, var.to_s)
    vars = ['one', 2, true].collect { |o| Wx::Variant.new(o) }
    var = Wx::Variant.new(vars)
    assert_equal(['one', 2, true].to_s, var.to_s)
  end

  def test_to_f
    var = Wx::Variant.new(1234)
    assert_equal((1234).to_f, var.to_f)
    var = Wx::Variant.new(1234.5678)
    assert_equal((1234.5678).to_f, var.to_f)
    var = Wx::Variant.new(2**64-1)
    assert_equal((2**64-1).to_f, var.to_f)
    var = Wx::Variant.new(1-(2**63))
    assert_equal((1-(2**63)).to_f, var.to_f)
    tm = Time.now
    var = Wx::Variant.new(tm)
    assert_equal(tm.round(3).to_f, var.to_f)
 end

end
