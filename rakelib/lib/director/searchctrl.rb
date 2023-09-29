# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './window'

module WXRuby3

  class Director

    class SearchCtrl < Window

      def setup
        super
        # mixin TextEntry
        spec.include_mixin 'wxSearchCtrl', { 'Wx::TextEntry' => 'wxTextEntryBase' }
        spec.suppress_warning(473, 'wxSearchCtrl::GetMenu')
        spec.override_inheritance_chain('wxSearchCtrl', %w[wxControl wxWindow wxEvtHandler wxObject])
      end
    end # class SearchCtrl

  end # class Director

end # module WXRuby3
