# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class MouseState < Director

      def setup
        super
        spec.ignore 'wxMouseState::GetPosition(int*,int*)'
        spec.do_not_generate(:variables, :defines, :functions)
      end
    end # class MouseState

  end # class Director

end # module WXRuby3
