###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './window'

module WXRuby3

  class Director

    class AnimationCtrl < Window

      include Typemap::IOStreams

      def setup
        super
        spec.do_not_generate :variables, :enums, :defines, :functions
      end
    end # class AnimationCtrl

  end # class Director

end # module WXRuby3
