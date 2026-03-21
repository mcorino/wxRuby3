# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './event'

module WXRuby3

  class Director

    class WebViewEvent < Event

      def setup
        super
        spec.override_inheritance_chain('wxWebViewEvent',
                                        {'wxNotifyEvent' => 'wxEvents'}, {'wxCommandEvent' => 'wxEvent'}, 'wxEvent', 'wxObject')
        if Config.instance.wx_version_check('3.3.0') >= 0
          spec.items << 'wxWebViewWindowFeatures'
          spec.gc_as_untracked 'wxWebViewWindowFeatures'
          spec.no_proxy 'wxWebViewWindowFeatures'
          spec.make_abstract 'wxWebViewWindowFeatures'
          spec.extend_interface 'wxWebViewWindowFeatures',
                                'virtual wxWebViewWindowFeatures()',
                                visibility: 'protected'

        end
        spec.do_not_generate(:variables, :defines, :enums, :functions)
      end
    end # class WebViewEvent

  end # class Director

end # module WXRuby3
