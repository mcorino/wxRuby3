#--------------------------------------------------------------------
# @file    sash_window.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

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
