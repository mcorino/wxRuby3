#--------------------------------------------------------------------
# @file    static_bitmap.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

module WXRuby3

  class Director

    class StaticBitmap < Window

      def setup
        spec.add_swig_runtime_code <<~__HEREDOC
          %constant char * wxStaticBitmapNameStr = wxStaticBitmapNameStr;
          __HEREDOC
        super
      end
    end # class StaticBitmap

  end # class Director

end # module WXRuby3
