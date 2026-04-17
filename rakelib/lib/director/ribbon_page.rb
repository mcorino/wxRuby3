# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './window'

module WXRuby3

  class Director

    class RibbonPage < Window

      def setup
        super
        if Config.instance.wx_version_check('3.3.2') <= 0
          # implement custom version of method because of unconventional
          # (and problematic) return type
          spec.ignore 'wxRibbonPage::GetIcon', ignore_doc: false
          spec.add_extend_code 'wxRibbonPage', <<~__CODE
            wxBitmap GetIcon()
            {
              return $self->GetIcon();
            }
            __CODE
        end
      end
    end # class RibbonPage

  end # class Director

end # module WXRuby3
