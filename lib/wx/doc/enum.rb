# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.


###
# wxRuby3 Enum class
###
# :startdoc:



module Wx

  # Base class for typed enums.
  # Derives from Numeric and behaves as such in math operations but provides
  # type safety for arguments requiring the specific enum class.
  class Enum < Numeric

    # Initialize a new enum value.
    # @param [Integer] val enum integer value
    def initialize(val)end

    # Coerces enum value to be compatible with other if possible. Raises TypeError if not compatible.
    # @param [Numeric] other numeric value
    # @return [Array<Integer, Integer>] the integer equivalences of other and enum value
    def coerce(other) end

    # Returns true.
    def integer?; end

    # Returns false.
    def real?; end

    # Redirects to the @value member attribute for any missing methods.
    def method_missing(sym, *args) end

    # Checks type and value equality.
    # @param [::Object] o the object to compare
    # @return [true,false] true if o is instance of same enum class as self **and** integer values are equal; false otherwise
    def eql?(o) end

    # Compares integer values if possible. Raises ArgumentError if not compatible
    # @param [Enum,Numeric] o enum or numeric object to compare.
    # @return [-1,0,1]
    def <=>(o) end

    # Returns bitwise or-ed value.
    # In case other is same class as self an enum instance of that class is returned
    # otherwise an Integer value.
    # @param [Wx::Enum,Integer] other
    # @return [Wx::Enum,Integer]
    def |(other) end

    # Returns bitwise and-ed value.
    # In case other is same class as self an enum instance of that class is returned
    # otherwise an Integer value.
    # @param [Wx::Enum,Integer] other
    # @return [Wx::Enum,Integer]
    def &(other) end

    # Returns an enum instance of the complement value (same class as self).
    # @return [Wx::Enum]
    def ~; end

    # Returns true if value is 0 otherwise false.
    # @return [Boolean]
    def !; end

    # Returns true if all bits that are set (=1) in mask are also set in self; returns false otherwise.
    # @param [Integer] mask
    # @return [Boolean]
    def allbits?(mask) end

    # Returns true if any bit that is set (=1) in mask is also set in self; returns false otherwise.
    # @param [Integer] mask
    # @return [Boolean]
    def anybits?(mask) end

    # Returns true if no bit that is set (=1) in mask is also set in self; returns false otherwise.
    # @param [Integer] mask
    # @return [Boolean]
    def nobits?(mask) end

    # Return next integer value from enum's value.
    # @return [Integer] next integer value
    def succ; end

    # Return string representation.
    def inspect; end

    # Return integer value of enum
    def to_int; end
    alias :to_i :to_int

    # Return string representation of enum value (mask).
    # In case the enum value matches a single enumerator value of the enum class the (scoped) name
    # of that enumerator is returned otherwise the enum mask value is analyzed and a string representation
    # of a bitwise **or** expression is returned matching the mask.
    def to_s; end

    # Create a new class and associated enum values.
    # @param [String,Symbol] name name of new enum class
    # @param [Hash] enum_values hash with enum value name and enum integer value pairs
    # @return [Class] new enum class
    def self.create(name, enum_values) end

    # Returns enum class matching name or nil.
    # @param [String,Symbol] name name of enum class
    # @return [Class,nil] enum class
    def self.[](name) end

  end

end
