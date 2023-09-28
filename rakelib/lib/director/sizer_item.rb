# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class SizerItem < Director

      def setup
        spec.disable_proxies
        # do not allow creating SizerItems in Ruby; this has limited benefits and
        # memory management of sizer items is a nightmare
        case spec.module_name
        when 'wxSizerItem'
          spec.make_abstract 'wxSizerItem'
          # ignore constructors
          spec.ignore 'wxSizerItem::wxSizerItem'
          spec.ignore(%w[wxSizerItem::SetSizer wxSizerItem::SetSpacer wxSizerItem::SetWindow])
        when 'wxGBSizerItem'
          spec.make_abstract 'wxGBSizerItem'
          # ignore constructors
          spec.ignore 'wxGBSizerItem::wxGBSizerItem'
          spec.ignore(%w[wxGBSizerItem::SetGBSizer])
          spec.do_not_generate :variables, :enums, :defines, :functions
        end
        super
      end
    end # class SizerItem

  end # class Director

end # module WXRuby3
