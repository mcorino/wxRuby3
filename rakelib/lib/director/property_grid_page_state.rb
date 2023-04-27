###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class PropertyGridPageState < Director

      def setup
        super
        spec.items << 'wxPropertyGridHitTestResult'
        spec.gc_never 'wxPropertyGridPageState'
        spec.gc_as_temporary 'wxPropertyGridHitTestResult'
        spec.make_abstract 'wxPropertyGridPageState'
        spec.disable_proxies
        spec.ignore 'wxPropertyGridPageState::DoDelete',
                    'wxPropertyGridPageState::DoInsert'
        if Config.instance.wx_version >= '3.3.0'
          spec.ignore 'wxPropertyGridPageState::DoSetSplitter'
        else
          spec.ignore 'wxPropertyGridPageState::DoSetSplitterPosition'
        end
        spec.do_not_generate :variables, :enums, :defines, :functions
      end
    end # class PropertyGridPageState

  end # class Director

end # module WXRuby3
