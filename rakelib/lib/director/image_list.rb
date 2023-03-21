###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class ImageList < Director

      def setup
        spec.require_app 'wxImageList'
        spec.rename_for_ruby('AddIcon' => 'wxImageList::Add(const wxIcon &)')
        super
      end
    end # class ImageList

  end # class Director

end # module WXRuby3
