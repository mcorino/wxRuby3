#--------------------------------------------------------------------
# @file    grid_range_select_event.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

require_relative './event'

module WXRuby3

  class Director

    class GridRangeSelectEvent < Event

      def setup
        super
        spec.ignore_bases('wxGridRangeSelectEvent' => %w[wxNotifyEvent]) # needed to suppress imports
        spec.swig_import('swig/classes/include/wxObject.h', 'swig/classes/include/wxEvent.h') # provide base definitions
        spec.override_base('wxGridRangeSelectEvent', 'wxNotifyEvent') # re-establish correct base
        spec.swig_import '../shared/grid_coords.i' # Typemaps for GridCoords
      end
    end # class GridRangeSelectEvent

  end # class Director

end # module WXRuby3
