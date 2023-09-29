# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class AuiToolBarItem < Director

      def setup
        super
        spec.gc_as_object
        spec.do_not_generate(:variables, :defines, :enums, :functions)
      end
    end # class AuiToolBarItem

  end # class Director

end # module WXRuby3
