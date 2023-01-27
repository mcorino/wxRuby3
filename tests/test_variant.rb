require 'test/unit'
require 'test/unit/ui/console/testrunner'
require 'wx'

class TestApp < Wx::App
  attr_accessor :test_class
  def on_init
    Test::Unit::UI::Console::TestRunner.run(self.test_class)
    GC.start
    false # exit after tests
  end
end

class TestVariant < Test::Unit::TestCase

  def test_basics
    var = Wx::Variant.new('text variant')
    assert_equal('text variant', var.get_string)
    var = Wx::Variant.new(true)
    assert_equal(true, var.get_bool)
    var = Wx::Variant.new(1234)
    assert_equal(1234, var.get_long)
    var = Wx::Variant.new(1234.5678)
    assert_equal(1234.5678, var.get_double)
    var = Wx::Variant.new(2**64-1)
    assert_equal(2**64-1, var.get_u_long_long)
    var = Wx::Variant.new(1-(2**63))
    assert_equal(1-(2**63), var.get_long_long)
    tm = Time.now
    var = Wx::Variant.new(tm)
    assert_equal(tm.round(3), var.get_date_time)
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
    assert_equal(font, var.get_wx_object)
  end

end

app = TestApp.new
app.test_class = TestVariant
app.run
