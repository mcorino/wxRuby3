# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class RichTextHeaderFooterData < Director

      def setup
        super
        spec.gc_as_untracked 'wxRichTextHeaderFooterData'
        spec.disable_proxies # fixed and final data structures
      end
    end # class RichTextHeaderFooterData

  end # class Director

end # module WXRuby3
