# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class SystemOptions < Director

      def setup
        super
        spec.gc_never
        spec.make_abstract 'wxSystemOptions'
        spec.disable_proxies
      end
    end # class SystemOptions

  end # class Director

end # module WXRuby3
