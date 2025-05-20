# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class PropertyGridPageState < Director

      def setup
        super
        spec.items << 'wxPropertyGridHitTestResult'
        spec.gc_never 'wxPropertyGridPageState'
        spec.gc_as_untracked 'wxPropertyGridHitTestResult'
        spec.make_abstract 'wxPropertyGridPageState'
        spec.disable_proxies
        spec.ignore 'wxPropertyGridPageState::DoDelete',
                    'wxPropertyGridPageState::DoInsert'
        if Config.instance.wx_version_check('3.3.0') >= 0
          spec.ignore 'wxPropertyGridPageState::DoSetSplitter'
        else
          spec.ignore 'wxPropertyGridPageState::DoSetSplitterPosition'
        end
        spec.do_not_generate :variables, :enums, :defines, :functions
      end
    end # class PropertyGridPageState

  end # class Director

end # module WXRuby3
