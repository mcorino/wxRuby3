###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './dialog'

module WXRuby3

  class Director

    class PageSetupDialog < Director::Dialog

      include Typemap::PrintData

      def setup
        super
      end
    end # class PageSetupDialog

  end # class Director

end # module WXRuby3
