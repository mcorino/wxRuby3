# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './window'

module WXRuby3

  class Director

    class Slider < Window

      def setup
        super
      end

      def process(gendoc: false)
        defmod = super
        # fix documentation errors for scroll events
        def_item = defmod.find_item('wxSlider')
        if def_item
          def_item.event_types.each do |evt_spec|
            case evt_spec.first
            when 'EVT_COMMAND_SCROLL_THUMBRELEASE', 'EVT_COMMAND_SCROLL_CHANGED'
              if evt_spec[2] == 0
                evt_spec[2] = 1       # incorrectly documented without 'id' argument
                evt_spec[4] = true    # ignore extracted docs
              end
            end
          end
        end
        defmod
      end
    end # class Slider

  end # class Director

end # module WXRuby3
