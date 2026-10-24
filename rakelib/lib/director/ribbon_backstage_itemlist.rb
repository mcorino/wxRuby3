# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './window'

module WXRuby3

  class Director

    class BackstageItemList < Window

      def setup
        super
        spec.gc_as_window 'wxBackstageItemList'
        spec.override_inheritance_chain('wxBackstageItemList', %w[wxScrolledCanvas wxWindow wxEvtHandler wxObject])
        spec.do_not_generate :variables, :enums, :defines, :functions, :typedefs
      end
    end # class BackstageItemList

  end # class Director

end # module WXRuby3
