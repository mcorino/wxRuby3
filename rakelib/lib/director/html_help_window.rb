# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
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
