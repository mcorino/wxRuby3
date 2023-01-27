###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class PGCell < Director

      def setup
        super
        spec.items << 'wxPGCellData' << 'wxPGChoiceEntry'
        spec.override_inheritance_chain('wxPGCellData', [])
        spec.make_abstract 'wxPGCellData' # there is never any need to create an instance in Ruby
        spec.no_proxy 'wxPGCellData'
        spec.gc_never 'wxPGCellData'
        spec.do_not_generate :variables, :enums, :defines, :functions # with PGProperty
      end
    end # class PGCell

  end # class Director

end # module WXRuby3
