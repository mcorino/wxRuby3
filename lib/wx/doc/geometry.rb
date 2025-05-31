# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.


###
# wxRuby3 2D geometry classes
###
# :startdoc:


module Wx

  # Convert degrees to radians.
  # @param [Float] deg degrees
  # @return [Float] radians
  def self.deg_to_rad(deg) end

  # Convert radians to degrees.
  # @param [Float] rad radians
  # @return [Float] degrees
  def self.rad_to_deg(rad) end

  class Point2DInt

    # @return [Integer]
    def get_x; end
    alias :x :get_x
    # @param [Integer] v
    # @return [Integer]
    def set_x(v) end
    alias :x= :set_x

    # @return [Integer]
    def get_y; end
    alias :y :get_y
    # @param [Integer] v
    # @return [Integer]
    def set_y(v) end
    alias :y= :set_y

    # @param [Wx::Point2DInt] pt
    # @return [self]
    def assign(pt) end

    # @param [Wx::Point2DInt] pt
    # @return [self]
    def add!(pt) end

    # @param [Wx::Point2DInt] pt
    # @return [self]
    def sub!(pt) end

    # @param [Wx::Point2DInt,Integer,Float] v
    # @return [self]
    def mul!(v) end

    # @param [Wx::Point2DInt,Integer,Float] v
    # @return [self]
    def div!(v) end

    # @param [Wx::Point2DInt] pt
    # @return [Wx::Point2DInt]
    def +(pt) end

    # @param [Wx::Point2DInt] pt
    # @return [Wx::Point2DInt]
    def -(pt) end

    # @param [Wx::Point2DInt,Integer,Float] v
    # @return [Wx::Point2DInt]
    def *(v) end

    # @param [Wx::Point2DInt,Integer,Float] v
    # @return [Wx::Point2DInt]
    def /(v) end

  end

  class Point2DDouble

    # @return [Float]
    def get_x; end
    alias :x :get_x
    # @param [Float] v
    # @return [Float]
    def set_x(v) end
    alias :x= :set_x

    # @return [Float]
    def get_y; end
    alias :y :get_y
    # @param [Float] v
    # @return [Float]
    def set_y(v) end
    alias :y= :set_y

    # @param [Wx::Point2DDouble] pt
    # @return [self]
    def assign(pt) end

    # @param [Wx::Point2DDouble] pt
    # @return [self]
    def add!(pt) end

    # @param [Wx::Point2DDouble] pt
    # @return [self]
    def sub!(pt) end

    # @param [Wx::Point2DDouble,Integer,Float] v
    # @return [self]
    def mul!(v) end

    # @param [Wx::Point2DDouble,Integer,Float] v
    # @return [self]
    def div!(v) end

    # @param [Wx::Point2DDouble] pt
    # @return [Wx::Point2DDouble]
    def +(pt) end

    # @param [Wx::Point2DDouble] pt
    # @return [Wx::Point2DDouble]
    def -(pt) end

    # @param [Wx::Point2DDouble,Integer,Float] v
    # @return [Wx::Point2DDouble]
    def *(v) end

    # @param [Wx::Point2DDouble,Integer,Float] v
    # @return [Wx::Point2DDouble]
    def /(v) end

  end

  class Rect2DDouble

    # @return [Float]
    def get_x; end
    alias :x :get_x
    # @param [Float] v
    # @return [Float]
    def set_x(v) end
    alias :x= :set_x

    # @return [Float]
    def get_y; end
    alias :y :get_y
    # @param [Float] v
    # @return [Float]
    def set_y(v) end
    alias :y= :set_y

    # @return [Float]
    def get_width; end
    alias :width :get_width
    # @param [Float] v
    # @return [Float]
    def set_width(v) end
    alias :width= :set_width

    # @return [Float]
    def get_height; end
    alias :height :get_height
    # @param [Float] v
    # @return [Float]
    def set_height(v) end
    alias :y= :set_height

    # @param [Wx::Rect2DDouble] pt
    # @return [self]
    def assign(pt) end

  end
end
