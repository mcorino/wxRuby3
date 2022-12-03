###
# wxRuby3 base Generator class
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative '../core/spec_helper'

module WXRuby3

  class Generator

    include DirectorSpecsHelper

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
