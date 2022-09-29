#--------------------------------------------------------------------
# @file    dialog.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

module WXRuby3

  class Director

    class Dialog < TopLevelWindow

      def setup
        spec.ignore('wxDialog::GetContentWindow')
        spec.swig_import('include/defs.h')
        super
      end
    end # class Dialog

  end # class Director

end # module WXRuby3
