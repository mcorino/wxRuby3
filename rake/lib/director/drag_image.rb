#--------------------------------------------------------------------
# @file    drag_image.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

module WXRuby3

  class Director

    class DragImage < Director

      def setup
        spec.set_only_for('__WXUNIVERSAL__', 'wxDragImage::DoDrawImage', 'wxDragImage::GetImageRect', 'wxDragImage::UpdateBackingFromWindow')
        super
      end
    end # class DragImage

  end # class Director

end # module WXRuby3
