# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './ctrl_with_items'

module WXRuby3

  class Director

    class DirFilterListCtrl < ControlWithItems

      def setup
        super
        setup_ctrl_with_items('wxDirFilterListCtrl')
        spec.override_inheritance_chain('wxDirFilterListCtrl',
                                        %w[wxChoice
                                           wxControlWithItems
                                           wxControl
                                           wxWindow
                                           wxEvtHandler
                                           wxObject])
      end
    end # class DirFilterListCtrl

  end # class Director

end # module WXRuby3
