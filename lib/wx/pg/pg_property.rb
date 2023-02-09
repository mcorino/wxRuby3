# Wx::PG::PGProperty
# Copyright (c) M.J.N. Corino, The Netherlands

module Wx::PG

  NullProperty = nil
  PGChoicesEmptyData = nil

  PG_LABEL = Wx::PG::PG_LABEL_STRING

  PG_DEFAULT_IMAGE_SIZE = Wx::DEFAULT_SIZE

  class PGProperty

    wx_each_attribute = instance_method :each_attribute
    define_method :each_attribute do |id|
      if block_given?
        wx_each_attribute.bind(self).call(id)
      else
        ::Enumerator.new { |y| wx_each_attribute.bind(self).call(id) { |variant| y << variant } }
      end
    end
    alias :attributes :each_attribute

    # add some 'smart' variant conversion to these methods

    wx_set_value = instance_method :set_value
    define_method :set_value do |val, *args|
      val = Wx::Variant.new(val) unless Wx::Variant === val
      wx_set_value.bind(self).call(val, *args)
    end
    alias :value= :set_value

    wx_set_default_value = instance_method :set_default_value
    define_method :set_value do |val|
      val = Wx::Variant.new(val) unless Wx::Variant === val
      wx_set_default_value.bind(self).call(val)
    end
    alias :default_value= :set_default_value

    wx_set_value_in_event = instance_method :set_value_in_event
    define_method :set_value_in_event do |val|
      val = Wx::Variant.new(val) unless Wx::Variant === val
      wx_set_value_in_event.bind(self).call(val)
    end
    alias :value_in_event= :set_value_in_event

  end

end
