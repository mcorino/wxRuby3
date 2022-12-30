###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class Cursor < Director

      def setup
        spec.ignore 'wxCursor::wxCursor(const char[],int,int,int,int,const char[])'
        spec.do_not_generate(%i[variables enums defines])
        super
      end
    end # class Cursor

  end # class Director

end # module WXRuby3
