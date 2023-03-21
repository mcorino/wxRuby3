###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class TextAttr < Director

      def setup
        super
        spec.gc_as_object('wxTextAttr')
        spec.ignore 'wxTextAttr::Merge(const wxTextAttr &,const wxTextAttr &)'
        spec.do_not_generate :variables, :defines, :enums, :functions
      end
    end # class TextAttr

  end # class Director

end # module WXRuby3
