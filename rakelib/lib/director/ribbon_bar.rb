# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './window'

module WXRuby3

  class Director

    class RibbonBar < Window

      def setup
        super
        # for SetArtProvider (only in RibbonBar)
        spec.disown 'wxRibbonArtProvider *art'
        spec.do_not_generate :variables, :enums, :defines, :functions
      end
    end # class RibbonBar

  end # class Director

end # module WXRuby3
