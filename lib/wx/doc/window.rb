# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx

  class Window

    # Lowers the window to the bottom of the window hierarchy (Z-order).
    # This method has been renamed in wxRuby to be consistent with the renamed #raise_window method.
    #
    # <div class="wxrb-remark">
    # <b>Remark:</b>
    # <p>This function only works for {Wx::TopLevelWindow}-derived classes.
    # </p>
    # </div>
    # @see Wx::Window#raise_window
    # @return [void]
    def lower_window; end
    alias :send_to_back :lower_window

    # Raises the window to the top of the window hierarchy (Z-order).
    # This method has been renamed in wxRuby to avoid clashing with the standard Kernel#raise method.
    #
    # Notice that this function only requests the window manager to raise this window to the top of Z-order. Depending
    # on its configuration, the window manager may raise the window, not do it at all or indicate that a window
    # requested to be raised in some other way, e.g. by flashing its icon if it is minimized.
    #
    # <div class="wxrb-remark">
    # <b>Remark:</b>
    # <p>This function only works for {Wx::TopLevelWindow}-derived classes.
    # </p>
    # </div>
    # @see Wx::Window#lower_window
    # @return [void]
    def raise_window; end
    alias :bring_to_front :raise_window

    # Creates an appropriate (temporary) DC to paint on and
    # passes that to the given block. Deletes the DC when the block returns.
    # Creates a Wx::PaintDC when called from an evt_paint handler and a
    # Wx::ClientDC otherwise.
    # @yieldparam [Wx::PaintDC,Wx::ClientDC] dc dc to paint on
    # @return [::Object] result from block
    def paint; end

    # Similar to #paint but this time creates a Wx::AutoBufferedPaintDC when called
    # from an evt_paint handler and a Wx::ClientDC otherwise.
    # @yieldparam [Wx::AutoBufferedPaintDC,Wx::ClientDC] dc dc to paint on
    # @return [::Object] result from block
    def paint_buffered; end

    # Yield each child window to the given block.
    # Returns an Enumerator if no block given.
    # @yieldparam [Wx::Window] child the child window yielded
    # @return [Object,Enumerator] last result of block or Enumerator if no block given.
    def each_child; end

    # Locks the window from updates while executing the given block.
    # @param [Proc] block
    def locked(&block); end

    # Find the first child window with the given id recursively in the window hierarchy of this window.
    #
    # Window with the given id or nil if not found.
    # @see Wx::Window.find_window_by_id
    # @param id [Integer]
    # @return [Wx::Window]
    def find_window_by_id(id) end

    # Find the first child window with the given label recursively in the window hierarchy of this window.
    #
    # Window with the given label or nil if not found.
    # @see Wx::Window.find_window_by_label
    # @param label [String]
    # @return [Wx::Window]
    def find_window_by_label(label) end

    # Find the first child window with the given name (as given in a window constructor or {Wx::Window#create} function call) recursively in the window hierarchy of this window.
    #
    # Window with the given name or nil if not found.
    # @param name [String]
    # @return [Wx::Window]
    def find_window_by_name(name) end

    # Switches the current sizer with the given sizer and detaches and returns the 'old' sizer.
    # @param [Wx::Sizer] new_sizer new sizer for window
    # @return [Wx::Sizer] previous window sizer
    def switch_sizer(new_sizer) end

  end

end
