#--------------------------------------------------------------------
# @file    help_controller.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

module WXRuby3

  class Director

    class HelpController < Director

      def setup
        super
        spec.items << 'wxHelpControllerBase'
        spec.fold_bases('wxHelpController' => 'wxHelpControllerBase')
        spec.rename_for_ruby('Init' => 'wxHelpController::Initialize')
      end
    end # class HelpController

  end # class Director

end # module WXRuby3
