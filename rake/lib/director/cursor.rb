#--------------------------------------------------------------------
# @file    cursor.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

module WXRuby3

  class Director

    class Cursor < Director

      def setup
        spec.ignore 'wxCursor::wxCursor(const char[],int,int,int,int,const char[])'
        super
      end
    end # class Cursor

  end # class Director

end # module WXRuby3
