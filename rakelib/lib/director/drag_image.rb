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
        # If wxRuby ever supports WXUNIVERSAL this should change to #ignore_unless
        spec.ignore('wxDragImage::DoDrawImage', 'wxDragImage::GetImageRect', 'wxDragImage::UpdateBackingFromWindow')
        super
      end
    end # class DragImage

  end # class Director

end # module WXRuby3
