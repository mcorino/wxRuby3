###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class Timer < Director

      def setup
        super
        spec.do_not_generate(:variables, :enums, :defines, :functions)
      end
    end # class Timer

  end # class Director

end # module WXRuby3
