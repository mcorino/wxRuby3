###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class FindReplaceData < Director

      def setup
        super
        spec.do_not_generate(:variables, :enums)
      end
    end # class FindReplaceData

  end # class Director

end # module WXRuby3
