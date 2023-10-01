# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

# Wx::PG::PGProperty

module Wx::PG

  NullProperty = nil
  PGChoicesEmptyData = nil

  PG_LABEL_STRING = '@!' unless self.const_defined?(:PG_LABEL_STRING) # disappeared >= wxWidgets 3.3.0
  PG_LABEL = Wx::PG::PG_LABEL_STRING

  PG_DEFAULT_IMAGE_SIZE = Wx::DEFAULT_SIZE

  class PGProperty

    wx_each_attribute = instance_method :each_attribute
    define_method :each_attribute do
      if block_given?
        wx_each_attribute.bind(self).call
      else
        ::Enumerator.new { |y| wx_each_attribute.bind(self).call { |variant| y << variant } }
      end
    end

    def get_attributes
      each_attribute.inject({}) { |map, v| map[v.name] = v; map }
    end
    alias :attributes :get_attributes

    def set_attributes(map)
      raise ArgumentError, 'Expected Hash' unless map.is_a?(::Hash)
      map.each_pair { |nm, v| set_attribute(nm, v) }
    end
    alias :attributes= :set_attributes
  end

end
