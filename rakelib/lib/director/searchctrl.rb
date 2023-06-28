###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './window'

module WXRuby3

  class Director

    class SearchCtrl < Window

      def setup
        super
        # mixin TextEntry
        spec.include_mixin 'wxSearchCtrl', 'Wx::TextEntry'
        spec.override_inheritance_chain('wxSearchCtrl', %w[wxControl wxWindow wxEvtHandler wxObject])
      end
    end # class SearchCtrl

  end # class Director

end # module WXRuby3
