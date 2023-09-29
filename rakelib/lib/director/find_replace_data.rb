# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class FindReplaceData < Director

      def setup
        super
        spec.gc_as_object 'wxFindReplaceData'
        spec.do_not_generate(:variables, :enums)
      end
    end # class FindReplaceData

  end # class Director

end # module WXRuby3
