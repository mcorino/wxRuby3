###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class PGValidationInfo < Director

      def setup
        super
        spec.items << 'propgrid/propgrid.h'
        spec.gc_as_temporary 'wxPGValidationInfo'
        spec.ignore 'wxPGVFBFlags' # not a constant but a rather a clumsy typedef
      end
    end # class PGValidationInfo

  end # class Director

end # module WXRuby3
