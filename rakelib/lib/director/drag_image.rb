# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class DragImage < Director

      include Typemap::TreeItemId

      def setup
        unless Config.instance.features_set?('__WXUNIVERSAL__')
          spec.ignore('wxDragImage::DoDrawImage', 'wxDragImage::GetImageRect', 'wxDragImage::UpdateBackingFromWindow')
        end
        super
      end
    end # class DragImage

  end # class Director

end # module WXRuby3
