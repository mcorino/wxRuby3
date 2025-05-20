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

    # Returns true if WXWIDGETS_VERSION >= ver
    # @param [String,Array(Integer)] ver version string or integer array (1-3)
    # @return [Boolean] true if WXWIDGETS_VERSION >= ver, false otherwise
    def self.at_least_wxwidgets?(ver) end

    # Returns true if WXWIDGETS_VERSION <= ver
    # @param [String,Array(Integer)] ver version string or integer array (1-3)
    # @return [Boolean] true if WXWIDGETS_VERSION <= ver, false otherwise
    def self.up_to_wxwidgets?(ver) end

    # Returns true if WXWIDGETS_VERSION < ver
    # @param [String,Array(Integer)] ver version string or integer array (1-3)
    # @return [Boolean] true if WXWIDGETS_VERSION < ver, false otherwise
    def before_wxwidgets?(ver) end

    # Returns true if WXWIDGETS_VERSION > ver
    # @param [String,Array(Integer)] ver version string or integer array (1-3)
    # @return [Boolean] true if WXWIDGETS_VERSION > ver, false otherwise
    def after_wxwidgets?(ver) end

  end

end
