# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './aui_notebook'

module WXRuby3

  class Director

    class AuiMDIClientWindow < AuiNotebook

      def setup
        super
        spec.suppress_warning(473, 'wxAuiMDIClientWindow::GetActiveChild')
        spec.do_not_generate(:variables, :defines, :enums, :functions)
      end
    end # class AuiMDIClientWindow

  end # class Director

end # module WXRuby3
