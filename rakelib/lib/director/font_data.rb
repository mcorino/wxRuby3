###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class FontData < Director

      def setup
        super
        spec.gc_as_untracked 'wxFontData'
        # add copy ctor missing from XML docs
        spec.extend_interface 'wxFontData',
                              'wxFontData(const wxFontData & other)'
      end
    end # class FontData

  end # class Director

end # module WXRuby3
