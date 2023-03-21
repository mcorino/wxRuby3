###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
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
