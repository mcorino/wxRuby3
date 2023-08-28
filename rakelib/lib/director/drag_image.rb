###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class DragImage < Director

      def setup
        unless Config.instance.features_set?('__WXUNIVERSAL__')
          spec.ignore('wxDragImage::DoDrawImage', 'wxDragImage::GetImageRect', 'wxDragImage::UpdateBackingFromWindow')
        end
        super
      end
    end # class DragImage

  end # class Director

end # module WXRuby3
