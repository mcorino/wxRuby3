#--------------------------------------------------------------------
# @file    tree_event.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

require_relative './event'

module WXRuby3

  class Director

    class TreeEvent < Event

      def setup
        super
        spec.ignore_bases('wxTreeEvent' => %w[wxNotifyEvent]) # needed to suppress imports
        spec.swig_import('swig/classes/include/wxObject.h', 'swig/classes/include/wxEvent.h') # provide base definitions
        spec.override_base('wxTreeEvent', 'wxNotifyEvent') # re-establish correct base
        # wxTreeItemId fixes - these typemaps convert them to ruby Integers
        spec.swig_include '../shared/treeitemid_typemaps.i'
      end
    end # class TreeEvent

  end # class Director

end # module WXRuby3
