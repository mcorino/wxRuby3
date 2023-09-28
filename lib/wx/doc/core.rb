# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx

  class << self
    # Returns trace level (always 0 if #wxrb_debug returns false)
    # In case #wxrb_debug returns true #wxrb_trace_level= is also defined)
    # @return [Integer]
    attr_reader :wrb_trace_level
  end

end
