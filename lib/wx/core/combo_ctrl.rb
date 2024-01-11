# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.


module Wx

  module ComboPopup

    def self.included(mod)
      unless mod == Wx::ComboPopupWx
        mod.class_eval { include Wx::ComboPopup::Methods }
      end
    end

    module Methods
      # Returns pointer to the associated parent {Wx::ComboCtrl}.
      # @return [Wx::ComboCtrl]
      # def get_combo_ctrl; end

      # The including class must implement this to initialize its internal variables.
      #
      # This method is called immediately after construction finishes. m_combo member variable has been initialized before the call.
      # @return [void]
      def init
      end

      # The including class may implement this to return true if it wants to delay call to {Wx::ComboPopup#create} until the popup is shown for the first time.
      #
      # It is more efficient, but on the other hand it is often more convenient to have the control created immediately.
      #
      # <div class="wxrb-remark">
      # <b>Remark:</b>
      # <p>Base implementation returns false.
      # </p>
      # </div>
      # @return [Boolean]
      def lazy_create
        false
      end

      # The including class must implement this to create the popup control.
      #
      # true if the call succeeded, false otherwise.
      # @param parent [Wx::Window]
      # @return [Boolean]
      def create(parent)
        false
      end

      # You only need to implement this member function if you create your popup class in non-standard way.
      #
      # The default implementation can handle both multiple-inherited popup control (as seen in {Wx::ComboCtrl} samples) and one allocated separately in heap.
      # If you do completely re-implement this function, make sure it calls Destroy() for the popup control and also deletes this object (usually as the last thing).
      # @return [void]
      def destroy_popup
      end

      # Implement to customize matching of value string to an item container entry.
      #
      # <div class="wxrb-remark">
      # <b>Remark:</b>
      # <p>Default implementation always return true and does not alter trueItem.
      # </p>
      # </div>
      # @param item [String]  String entered, usually by user or from SetValue() call.
      # @param trueItem [Boolean] if true the true item string should be returned in case matching but different
      # @return [Boolean, String] Returns true if a match is found or false if not. If trueItem == true and item matches an entry, but the entry's string representation is not exactly the same (case mismatch, for example), then the true item string should be returned as the match result.
      def find_item(item, trueItem=false)
        true
      end

      # The including class may implement this to return adjusted size for the popup control, according to the variables given.
      #
      # <div class="wxrb-remark">
      # <b>Remark:</b>
      # <p>This function is called each time popup is about to be shown.
      # </p>
      # </div>
      # @param minWidth [Integer]  Preferred minimum width.
      # @param prefHeight [Integer]  Preferred height. May be -1 to indicate no preference.
      # @param maxHeight [Integer]  Max height for window, as limited by screen size.
      # @return [Wx::Size]
      def get_adjusted_size(minWidth, prefHeight, maxHeight)
        Wx::Size.new(minWidth, prefHeight)
      end

      # The including class must implement this to return pointer to the associated control created in {Wx::ComboPopup#create}.
      # @return [Wx::Window]
      def get_control
      end

      # The including class must implement this to receive string value changes from {Wx::ComboCtrl}.
      # @param value [String]
      # @return [void]
      def set_string_value(value)
      end

      # The including class must implement this to return string representation of the value.
      # @return [String]
      def get_string_value
        nil
      end

      # The including class may implement this to do something when the parent {Wx::ComboCtrl} gets double-clicked.
      # @return [void]
      def on_combo_double_click
      end

      # The including class may implement this to receive key down events from the parent {Wx::ComboCtrl}.
      #
      # Events not handled should be skipped, as usual.
      # @param event [Wx::KeyEvent]
      # @return [void]
      def on_combo_key_event(event)
        event.skip
      end

      # The including class may implement this to receive char events from the parent {Wx::ComboCtrl}.
      #
      # Events not handled should be skipped, as usual.
      # @param event [Wx::KeyEvent]
      # @return [void]
      def on_combo_char_event(event)
        event.skip
      end

      # The including class may implement this to do special processing when popup is hidden.
      # @return [void]
      def on_dismiss
      end

      # The including class may implement this to do special processing when popup is shown.
      # @return [void]
      def on_popup
      end

      # The including class may implement this to paint the parent {Wx::ComboCtrl}.
      # This is called to custom paint in the combo control itself (ie. not the popup).
      #
      # Default implementation draws value as string.
      # @param dc [Wx::DC]
      # @param rect [Wx::Rect]
      # @return [void]
      def paint_combo_control(dc, rect)
        combo = get_combo_ctrl
        if combo.get_window_style.allbits?(Wx::CB_READONLY) # ie. no textctrl
          combo.prepare_background(dc, rect,0)

          dc.draw_text(combo.get_value,
                       rect.x + combo.get_margin_left,
                       (rect.height-dc.get_char_height)/2 + rect.y)
        end
      end

    end

  end

  class ComboPopupWx

    include ComboPopup

    # this method has not been wrapped as a default popup control will always already have been
    # initialized before returned from #get_combo_control
    # just do nothing here (or should we raise an exception?)
    def init; end

  end

end
