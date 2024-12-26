# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

# Wx::PG property (and related) classes

module Wx::PG

  class SystemColourProperty < EnumProperty

    # add some 'smart' conversions
    wx_initialize = instance_method :initialize
    wx_redefine_method :initialize do |label=Wx::PG_LABEL, name=Wx::PG_LABEL, value=Wx::PG::ColourPropertyValue.new|
      value = case value
              when Wx::Colour
                Wx::PG::ColourPropertyValue.new(value)
              when Integer
                Wx::PG::ColourPropertyValue.new(value)
              else
                value
              end
      wx_initialize.bind(self).call(label, name, value)
    end

  end

end
