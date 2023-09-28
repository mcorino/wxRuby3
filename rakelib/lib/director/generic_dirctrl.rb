# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class GenericDirCtrl < Window

      include Typemap::TreeItemId

      def setup
        super
        spec.no_proxy 'wxGenericDirCtrl'
        spec.do_not_generate(:variables, :defines, :enums, :functions) # already with DirFilterListCtrl
      end

    end # class GenericDirCtrl

  end # class Director

end # module WXRuby3
