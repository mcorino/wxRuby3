# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './window'

module WXRuby3

  class Director

    class PGMultiButton < Window

      def setup
        super
        spec.do_not_generate :variables, :enums, :defines, :functions
      end
    end # class PGMultiButton

  end # class Director

end # module WXRuby3
