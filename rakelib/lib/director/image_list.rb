###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class ImageList < Director

      def setup
        spec.require_app 'wxImageList'
        if Config.instance.windows? || Config.instance.macosx?
          spec.ignore('wxImageList::Add(const wxIcon &)', ignore_doc: false)
        end
        super
      end
    end # class ImageList

  end # class Director

end # module WXRuby3
