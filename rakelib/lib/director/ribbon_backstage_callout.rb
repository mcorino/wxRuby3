# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './window'

module WXRuby3

  class Director

    class BackstageCallout < Window

      def setup
        super
        spec.no_proxy('wxBackstageCallout')
        spec.do_not_generate :variables, :enums, :defines, :functions, :typedefs
      end
    end # class BackstageCallout

  end # class Director

end # module WXRuby3
