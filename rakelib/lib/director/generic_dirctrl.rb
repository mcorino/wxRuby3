###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
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
