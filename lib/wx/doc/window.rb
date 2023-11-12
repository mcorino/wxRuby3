# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx

  class Window

    # Creates an appropriate (temporary) DC to paint on and
    # passes that to the given block. Deletes the DC when the block returns.
    # Creates a Wx::PaintDC when called from an evt_paint handler and a
    # Wx::ClientDC otherwise.
    # @yieldparam [Wx::PaintDC,Wx::ClientDC] dc dc to paint on
    # @return [Object] result from block
    def paint; end

    # Similar to #paint but this time creates a Wx::AutoBufferedPaintDC when called
    # from an evt_paint handler and a Wx::ClientDC otherwise.
    # @yieldparam [Wx::AutoBufferedPaintDC,Wx::ClientDC] dc dc to paint on
    # @return [Object] result from block
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
