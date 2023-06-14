###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './event'

module WXRuby3

  class Director

    class Events < Event

      def setup
        super
        spec.items.replace(%w[
          wxIdleEvent wxNotifyEvent wxScrollEvent wxScrollWinEvent wxMouseEvent wxMouseState
          wxSetCursorEvent wxGestureEvent wxPanGestureEvent wxZoomGestureEvent wxRotateGestureEvent
          wxTwoFingerTapEvent wxLongPressEvent wxPressAndTapEvent wxKeyEvent wxKeyboardState
          wxSizeEvent wxMoveEvent wxPaintEvent wxEraseEvent wxFocusEvent wxActivateEvent
          wxInitDialogEvent wxMenuEvent wxCloseEvent wxShowEvent wxIconizeEvent wxMaximizeEvent
          wxFullScreenEvent wxJoystickEvent wxDropFilesEvent wxUpdateUIEvent wxSysColourChangedEvent
          wxMouseCaptureChangedEvent wxMouseCaptureLostEvent wxDisplayChangedEvent wxDPIChangedEvent
          wxPaletteChangedEvent wxQueryNewPaletteEvent wxNavigationKeyEvent wxWindowCreateEvent
          wxWindowDestroyEvent wxHelpEvent wxClipboardTextEvent wxContextMenuEvent wxChildFocusEvent
          ])
        spec.fold_bases('wxMouseEvent' => %w[wxMouseState wxKeyboardState], 'wxKeyEvent' => 'wxKeyboardState')
        spec.set_only_for 'WXWIN_COMPATIBILITY_2_8', 'wxShowEvent::GetShow', 'wxIconizeEvent::Iconized'
        spec.ignore 'wxKeyEvent::GetPosition(wxCoord *,wxCoord *) const'
        spec.ignore 'wxMouseState::GetPosition(int *,int *)'
        spec.ignore 'wxShowEvent::GetShow', 'wxIconizeEvent::Iconized'
        spec.do_not_generate(:variables, :defines, :enums, :functions)
      end

      def process(gendoc: false)
        defmod = super
        # fix documentation errors for wxScrollEvent
        def_item = defmod.find_item('wxScrollEvent')
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

    end # class Events

  end # class Director

end # module WXRuby3
