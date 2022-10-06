#--------------------------------------------------------------------
# @file    image_list.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

module WXRuby3

  class Director

    class ImageList < Director

      def setup
        spec.rename_for_ruby('AddIcon' => 'wxImageList::Add(const wxIcon& icon)')
        super
      end
    end # class ImageList

  end # class Director

end # module WXRuby3
