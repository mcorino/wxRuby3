# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class GDIObject < Director

      def setup
        spec.make_abstract('wxGDIObject')
        spec.no_proxy('wxGDIObject')
        spec.gc_as_untracked 'wxGDIObject'
        super
      end
    end # class GDIObject

  end # class Director

end # module WXRuby3
