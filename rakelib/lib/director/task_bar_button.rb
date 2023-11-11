# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class TaskBarButton < Director

      def setup
        super
        spec.items << 'wxThumbBarButton'
        spec.no_proxy 'wxTaskBarButton'
        spec.gc_as_untracked 'wxTaskBarButton', 'wxThumbBarButton'
        spec.disown 'wxThumbBarButton *button'
        # superfluous and causing trouble for disown policy (re-implemented in pure Ruby)
        spec.ignore 'wxTaskBarButton::RemoveThumbBarButton(wxThumbBarButton*)', ignore_doc: false
        spec.new_object 'wxTaskBarButton::RemoveThumbBarButton(int)'
      end

    end

  end

end
