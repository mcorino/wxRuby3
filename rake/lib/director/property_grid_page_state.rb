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
        spec.ignore 'wxPropertyGridPageState::DoSetSplitterPosition',
                    'wxPropertyGridPageState::DoDelete',
                    'wxPropertyGridPageState::DoInsert'
        spec.do_not_generate :variables, :enums, :defines, :functions
      end
    end # class PropertyGridPageState

  end # class Director

end # module WXRuby3
