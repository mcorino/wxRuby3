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
        spec.gc_as_temporary 'wxPropertyGridHitTestResult'
        spec.gc_as_temporary 'wxPropertyGridPageState' # actually no GC control necessary as this is a mixin only
        # turn wxPropertyGridPageState into a mixin module
        spec.make_mixin 'wxPropertyGridPageState'
        # do not feel we need this in wxRuby
        spec.ignore %w[wxPropertyGridPageState::DoDelete wxPropertyGridPageState::DoInsert wxPropertyGridPageState::DoSetSplitterPosition]
      end
    end # class PropertyGridPageState

  end # class Director

end # module WXRuby3
