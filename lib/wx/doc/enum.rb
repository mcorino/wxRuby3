###
# wxRuby3 Enum class
# Copyright (c) M.J.N. Corino, The Netherlands
###

module Wx

  # Base class for typed enums.
  # Derives from Numeric and behaves as such in math operations but provides
  # type safety for arguments requiring the specific enum class.
  class Enum < Numeric

    # Initialize a new enum value.
    # @param [Integer] val enum integer value
    def initialize(val)
      @value = val.to_i
    end

    # Coerces enum value to be compatible with other if possible. Raises TypeError if not compatible.
    # @param [Numeric] other numeric value
    # @return [Array<Integer, Integer>] the integer equivalences of other and enum value
    def coerce(other)
      if Numeric === other
        return other.to_i, @value
      else
        raise TypeError, "Unable to coerce #{other} to be compatible with #{self}"
      end
    end

    # Returns true.
    def integer?
      true
    end

    # Returns false.
    def real?
      false
    end

    # Redirects to the @value member attribute for any missing methods.
    def method_missing(sym, *args)
      @value.__send__(sym, *args)
    end

    # Checks type and value equality.
    # @param [Object] o the object to compare
    # @return [true,false] true if o is instance of same enum class as self **and** integer values are equal; false otherwise
    def eql?(o)
      if Enum === o
        o.class == self.class && @value == o.to_i
      else
        false
      end
    end

    # Compares integer values if possible. Raises ArgumentError if not compatible
    # @param [Enum,Numeric] o enum or numeric object to compare.
    # @return [-1,0,1]
    def <=>(o)
      if Enum === o
        @value <=> o.to_i
      elsif Numeric === o
        @value <=> o
      else
        raise ArgumentError, "Failed to compare Enum with #{o.class.name}"
      end
    end

    # Return string representation.
    def inspect
      "#{self.class.name}<#{@value}>"
    end

    class << self
      def enums
        @enums ||= {}
      end
      private :enums

      # Create a new class and associated enum values.
      # @param [String,Symbol] name name of new enum class
      # @param [Hash] enum_values hash with enum value name and enum integer value pairs
      # @return [Class] new enum class
      def create(name, enum_values)
        enum_klass = Class.new(self)
        raise ArgumentError, "Invalid enum_values; expected Hash but got #{enum_values}." unless ::Hash === enum_values
        enum_values.each_pair { |nm,v| enum_klass.const_set(nm, enum_klass.new(v.to_i)) }
        enums[name.to_sym] = enum_klass
      end

    end

    # Returns enum class matching name or nil.
    # @param [String,Symbol] name name of enum class
    # @return [Class,nil] enum class
    def self.[](name)
      enums[name.to_sym]
    end

  end

end
