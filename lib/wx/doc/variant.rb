
class Wx::Variant

  include ::Enumerable

  # When a block is given iterates all items of a variant list passing
  # each item to the block.
  # Returns an enumerator when no block is given.
  # @overload each(&block)
  #   @yieldparam item [Wx::Variant] variant list item
  #   @return [Object] result of last block execution
  # @overload each
  #   @return [Enumerator] an enumerator
  def each; end

  # Replaces the value of the current variant with the given value
  # @overload assign(value)
  #   Equality test operator.
  #   @param value [Wx::Variant]
  #   @return [self]
  # @overload assign(value)
  #   Equality test operator.
  #   @param value [String]
  #   @return [self]
  # @overload assign(value)
  #   Equality test operator.
  #   @param value [Integer]
  #   @return [self]
  # @overload assign(value)
  #   Equality test operator.
  #   @param value [true,false]
  #   @return [self]
  # @overload assign(value)
  #   Equality test operator.
  #   @param value [Float]
  #   @return [self]
  # @overload assign(value)
  #   Equality test operator.
  #   @param value [Integer]
  #   @return [self]
  # @overload assign(value)
  #   Equality test operator.
  #   @param value [Integer]
  #   @return [self]
  # @overload assign(value)
  #   Equality test operator.
  #   @param value [Object]
  #   @return [self]
  # @overload assign(value)
  #   Equality test operator.
  #   @param value [Wx::Object]
  #   @return [self]
  # @overload assign(value)
  #   Equality test operator.
  #   @param value [Array<Wx::Variant>]
  #   @return [self]
  # @overload assign(value)
  #   Equality test operator.
  #   @param value [Array<String>]
  #   @return [self]
  # @overload assign(value)
  #   Equality test operator.
  #   @param value [Time,Date,DateTime]
  #   @return [self]
  def assign(*args) end
  alias :<< :assign

  # Convert contained object to integer value if possible.
  # Raises TypeError exception if incompatible.
  # @return [Integer] integer value
  def to_i; end

  # Convert contained object to floating point value if possible.
  # Raises TypeError exception if incompatible.
  # @return [Float] floating point value
  def to_f; end

  # Convert contained object to string value if possible.
  # Raises TypeError exception if incompatible.
  # @return [String] string value
  def to_s; end

  # Checks if Variant contains a String value (not null).
  # @return [true,false]
  def string?; end

  # Checks if Variant contains a boolean value (not null).
  # @return [true,false]
  def bool?; end

  # Checks if Variant contains a long value (not null).
  # @return [true,false]
  def long?; end

  # Checks if Variant contains a long long value (not null).
  # @return [true,false]
  def long_long?; end

  # Checks if Variant contains an unsigned long long value (not null).
  # @return [true,false]
  def u_long_long?; end

  # Checks if Variant contains an integer value (long|long long|unsigned long long).
  # @return [true,false]
  def integer?; end

  # Checks if Variant contains a (wx)DateTime value (not null).
  # (Note that the DateTime values in question concern wxDateTime
  # and not the Ruby DateTime class; in fact wxDateTime is normally
  # returned as a Ruby Time value)
  # @return [true,false]
  def date_time?; end

  # Checks if Variant contains a double value (not null).
  # @return [true,false]
  def double?; end

  # Checks if Variant contains an integer value (integer | double).
  # @return [true,false]
  def numeric?; end

  # Checks if Variant contains a VariantList (array of Variant) value (not null).
  # @return [true,false]
  def list?; end

  # Checks if Variant contains an ArrayString (array of String) value (not null).
  # @return [true,false]
  def array_string?; end

  # Checks if Variant contains a Font value (not null).
  # @return [true,false]
  def font?; end

  # Returns font value.
  # @return [Wx::Font]
  def get_font; end
  alias :font :get_font

  # Checks if Variant contains a Colour value (not null).
  # @return [true,false]
  def colour?; end

  # Returns colour value.
  # @return [Wx::Colour]
  def get_colour; end
  alias :colour :get_colour

  # Checks if Variant contains a ColourPropertyValue value (not null).
  # @return [true,false]
  def colour_property_value?; end

  # Returns colour property value.
  # @return [Wx::PG::ColourPropertyValue]
  def get_colour_property_value; end
  alias :colour_property_value :get_colour_property_value

  # Checks if Variant contains an unspecified Ruby object (not null or
  # nil and not one of the other value types).
  # @param [Class] klass the (base) class of the Ruby object to check
  # @return [true,false]
  def object?(klass=Object) end

end
