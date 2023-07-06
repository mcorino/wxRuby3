###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class TextEntry < Director

      def setup
        super
        spec.items << 'wxTextCompleter' << 'wxTextCompleterSimple'
        spec.gc_as_untracked 'wxTextCompleter', 'wxTextCompleterSimple'
        spec.gc_as_untracked 'wxTextEntry' # actually no GC control necessary as this is a mixin only
        # turn wxTextEntry into a mixin module
        spec.make_mixin 'wxTextEntry'
        # !!NOTE!!
        # This is not very nice but it is the easiest way to work around the problem that
        # what we actually want as native type is wxTextEntryBase (because of some bad implementation decisions in wxw)
        # and what is documented is wxTextEntry.
        spec.add_header_code '#define wxTextEntry wxTextEntryBase'
        spec.disown 'wxTextCompleter *completer' # managed by wxWidgets after passing in
        spec.map_apply 'long * OUTPUT' => 'long *' # for GetSelection
      end
    end # class TextEntry

  end # class Director

end # module WXRuby3
