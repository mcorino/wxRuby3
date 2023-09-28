# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class EventFilter < Director

      def setup
        super
        spec.gc_as_untracked # no tracking
      end
    end # class EventFilter

  end # class Director

end # module WXRuby3
