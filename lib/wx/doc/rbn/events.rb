# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx

  class EvtHandler

    # @!group RBN Event handler methods

    # Respond to {Wx::RBN::EVT_BACKSTAGE_CLICKED} event.
    # Triggered when a button on the left is clicked or activated. The event's ID is the button's ID. Call Wx::NotifyEvent#veto to keep the button's page from being shown.
    # @param [Integer,Wx::Enum,Wx::Window,Wx::MenuItem,Wx::ToolBarTool,Wx::Timer] id window/control id
    # @param [String,Symbol,Method,Proc] meth (name of) method or handler proc
    # @yieldparam [Wx::NotifyEvent] event the event to handle
    def evt_backstage_clicked(id, meth = nil, &block) end

    # Respond to {Wx::RBN::EVT_BACKSTAGE_ITEM_CLICKED} event.
    # Triggered when an item is clicked or activated. Wx::CommandEvent#get_int returns the item's index (not counting headers) and Wx::CommandEvent#get_string returns the item's user string (e.g., a file path).
    # @param [Integer,Wx::Enum,Wx::Window,Wx::MenuItem,Wx::ToolBarTool,Wx::Timer] id window/control id
    # @param [String,Symbol,Method,Proc] meth (name of) method or handler proc
    # @yieldparam [Wx::CommandEvent] event the event to handle
    def evt_backstage_item_clicked(id, meth = nil, &block) end

    # @!endgroup

  end

end
