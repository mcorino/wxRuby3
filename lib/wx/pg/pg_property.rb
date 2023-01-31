# Wx::PG::PGProperty
# Copyright (c) M.J.N. Corino, The Netherlands

module Wx::PG

  NullProperty = nil
  PGChoicesEmptyData = nil

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
