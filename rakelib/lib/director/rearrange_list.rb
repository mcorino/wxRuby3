# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './ctrl_with_items'

module WXRuby3

  class Director

    class RearrangeList < ControlWithItems

      include Typemap::ArrayIntSelections

      def setup
        super
        setup_ctrl_with_items('wxRearrangeList')
        spec.override_inheritance_chain('wxRearrangeList',
                                        %w[wxCheckListBox
                                           wxListBox
                                           wxControlWithItems
                                           wxControl
                                           wxWindow
                                           wxEvtHandler
                                           wxObject])
      end

    end # class RearrangeList

  end # class Director

end # module WXRuby3
