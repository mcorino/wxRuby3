# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 base Generator class
###

require_relative '../core/spec_helper'

module WXRuby3

  class Generator

    include DirectorSpecsHelper

    private

    attr_reader :director

    public

    def initialize(dir)
      @director = dir
    end

    def run
    end

    def to_s
      "<#{ifspec.module_name}>"
    end

    def inspect
      to_s
    end

  end # class Generator

end # module WXRuby3
