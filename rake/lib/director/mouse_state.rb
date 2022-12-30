###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class MouseState < Director

      def setup
        super
        spec.ignore 'wxMouseState::GetPosition(int*,int*)'
        spec.do_not_generate(:variables, :enums, :defines, :functions)
      end
    end # class MouseState

  end # class Director

end # module WXRuby3
