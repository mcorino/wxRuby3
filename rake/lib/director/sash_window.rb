###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './window'

module WXRuby3

  class Director

    class SashWindow < Window

      def setup
        super
        spec.add_swig_code 'enum wxSashEdgePosition;'
        spec.do_not_generate(:variables, :enums, :defines, :functions)
      end
    end # class SashWindow

  end # class Director

end # module WXRuby3
