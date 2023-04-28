# Wx::PG::PGProperty
# Copyright (c) M.J.N. Corino, The Netherlands

module Wx::PG

  NullProperty = nil
  PGChoicesEmptyData = nil

  PG_LABEL_STRING = '@!' unless self.const_defined?(:PG_LABEL_STRING) # disappeared >= wxWidgets 3.3.0
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
  end

end
