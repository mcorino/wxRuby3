# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './window'

module WXRuby3

  class Director

    class Backstage < Window

      def setup
        super
        spec.no_proxy('wxBackstage', 'wxBackstagePage')
        spec.items << 'wxBackstagePage'
        spec.gc_as_window 'wxBackstagePage'
        spec.override_inheritance_chain('wxBackstagePage', %w[wxScrolledWindow wxPanel wxWindow wxEvtHandler wxObject])
      end
    end # class Backstage

  end # class Director

end # module WXRuby3
