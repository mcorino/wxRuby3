# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class GUIEventLoop < Director

      def setup
        super
        spec.items << 'wxEventLoopBase'
        spec.gc_as_untracked
        spec.disable_proxies
        spec.make_concrete 'wxGUIEventLoop'
        spec.fold_bases 'wxGUIEventLoop' => 'wxEventLoopBase'
        spec.ignore 'wxEventLoopBase::GetActive',
                    'wxEventLoopBase::SetActive'
      end
    end # class GUIEventLoop

  end # class Director

end # module WXRuby3
