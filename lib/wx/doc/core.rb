
module Wx

  class << self
    # Returns true if wxRuby built in debug mode, false otherwise.
    # @return [Boolean]
    attr_reader :wxrb_debug

    # Returns trace level (always 0 if #wxrb_debug returns false)
    # In case #wxrb_debug returns true #wxrb_trace_level= is also defined)
    # @return [Integer]
    attr_reader :wrb_trace_level
  end

  # true if wxRuby built in debug mode, false otherwise.
  RB_DEBUG = wxrb_debug

end
