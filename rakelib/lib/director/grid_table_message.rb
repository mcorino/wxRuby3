# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class GridTableMessage < Director

      def setup
        super
        spec.gc_as_untracked
      end
    end # class GridTableMessage

  end # class Director

end # module WXRuby3
