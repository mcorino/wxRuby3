# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx

  # Mixin module providing Array extensions.
  module ArrayExt

    # Returns a new Wx::Size instance created from the first two elements of the array.
    # Any missing element will be supplemented by a Wx::DEFAULT_COORD value.
    # The array is not altered.
    # @return [Wx::Size]
    def to_size; end

    # Returns a new Wx::Point instance created from the first two elements of the array.
    # Any missing element will be supplemented by a Wx::DEFAULT_COORD value.
    # The array is not altered.
    # @return [Wx::Point]
    def to_point; end

    # Returns a new Wx::RealPoint instance created from the first two elements of the array.
    # Any missing element will be supplemented by a Wx::DEFAULT_COORD value.
    # The array is not altered.
    # @return [Wx::RealPoint]
    def to_real_point; end
    alias :to_real :to_real_point

  end

end
