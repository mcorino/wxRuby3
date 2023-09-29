# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
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
