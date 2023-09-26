###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './window'

module WXRuby3

  class Director

    class HtmlHelpWindow < Window

      include Typemap::ConfigBase

      def setup
        super
        # only allow setting config through propagation from help controller
        # saves us from management code
        spec.ignore 'wxHtmlHelpWindow::UseConfig'
      end

    end

  end

end
