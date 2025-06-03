# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx

  class GraphicsMatrix < GraphicsObject

    # Applies this matrix to a point.
    # @param [Wx::Point2DDouble,Array(Float,Float)] pt
    # @return [Wx::Point2DDouble]
    def transform_point(pt); end

    # Applies this matrix to a distance (i.e., performs all transforms except translations)..
    # @param [Wx::Point2DDouble,Array(Float,Float)] p
    # @return [Wx::Point2DDouble]
    def transform_distance(p); end

  end

end
