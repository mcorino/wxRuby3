
module Wx

  class << self
    # Returns trace level (always 0 if #wxrb_debug returns false)
    # In case #wxrb_debug returns true #wxrb_trace_level= is also defined)
    # @return [Integer]
    attr_reader :wrb_trace_level
  end

end
