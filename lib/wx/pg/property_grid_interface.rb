# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

module Wx::PG

  # since wxWidgets 3.3.0
  unless const_defined?(:PG_GETPROPERTYVALUES_FLAGS)
    module PG_GETPROPERTYVALUES_FLAGS
      PG_DONT_RECURSE = PGPropertyValuesFlags::DontRecurse
      PG_KEEP_STRUCTURE = PGPropertyValuesFlags::KeepStructure
      PG_RECURSE = PGPropertyValuesFlags::Recurse
      PG_INC_ATTRIBUTES = PGPropertyValuesFlags::IncAttributes
      PG_RECURSE_STARTS = PGPropertyValuesFlags::RecurseStarts
      PG_FORCE = PGPropertyValuesFlags::Force
      PG_SORT_TOP_LEVEL_ONLY = PGPropertyValuesFlags::SortTopLevelOnly
    end
  end
  
  module PropertyGridInterface

    wx_set_property_value = instance_method :set_property_value
    wx_redefine_method :set_property_value do |propid, value|
      case value
      when ::String
        set_property_value_string(propid, value)
      else
        wx_set_property_value.bind(self).call(propid, value)
      end
    end

    wx_each_property = instance_method :each_property
    wx_redefine_method :each_property do |flags = Wx::PG::PG_ITERATE_DEFAULT, start = nil, reverse: false, &block|
      if block
        wx_each_property.bind(self).call(flags.to_int, start, reverse, &block)
      else
        ::Enumerator.new { |y| wx_each_property.bind(self).call(flags.to_int, start, reverse) { |prop| y << prop } }
      end
    end
    alias :properties :each_property

    def reverse_each_property(flags = Wx::PG::PG_ITERATE_DEFAULT, start = nil, &block)
      each_property(flags, start, reverse: true, &block)
    end
    alias :properties_reversed :reverse_each_property

    wx_each_property_attribute = instance_method :each_property_attribute
    wx_redefine_method :each_property_attribute do |id, &block|
      if block
        wx_each_property_attribute.bind(self).call(id, &block)
      else
        ::Enumerator.new { |y| wx_each_property_attribute.bind(self).call(id) { |variant| y << variant } }
      end
    end
    alias :property_attributes :each_property_attribute

  end

end
