# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

module Wx
  class Point2DInt

    alias :x :get_x
    alias :x= :set_x
    alias :y :get_y
    alias :y= :set_y

    # make wrappers private
    private :add, :sub, :mul, :div

    wx_assign = instance_method :assign
    define_method :assign do |pt|
      wx_assign.bind(self).call(pt)
      self
    end

    def add!(pt)
      add(pt)
      self
    end

    def sub!(pt)
      sub(pt)
      self
    end

    def mul!(v)
      mul(v)
      self
    end

    def div!(v)
      div(v)
      self
    end

    def +(pt)
      Point2DInt.new(self).add!(pt)
    end

    def -(pt)
      Point2DInt.new(self).sub!(pt)
    end

    def *(v)
      Point2DInt.new(self).mul!(v)
    end

    def /(v)
      Point2DInt.new(self).div!(v)
    end

  end
  class Point2DDouble

    alias :x :get_x
    alias :x= :set_x
    alias :y :get_y
    alias :y= :set_y

    # make wrappers private
    private :add, :sub, :mul, :div

    wx_assign = instance_method :assign
    define_method :assign do |pt|
      wx_assign.bind(self).call(pt)
      self
    end

    def add!(pt)
      add(pt)
      self
    end

    def sub!(pt)
      sub(pt)
      self
    end

    def mul!(v)
      mul(v)
      self
    end

    def div!(v)
      div(v)
      self
    end

    def +(pt)
      Point2DDouble.new(self).add!(pt)
    end

    def -(pt)
      Point2DDouble.new(self).sub!(pt)
    end

    def *(v)
      Point2DDouble.new(self).mul!(v)
    end

    def /(v)
      Point2DDouble.new(self).div!(v)
    end

  end
end
