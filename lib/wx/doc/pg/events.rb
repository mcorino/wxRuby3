# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


class Wx::EvtHandler

  # @!group PG Event handler methods

  # Respond to {Wx::PG::EVT_PG_PAGE_CHANGED} event, generated when selected property page has been changed by the user.
  # Processes a {Wx::PG::EVT_PG_PAGE_CHANGED} event.
  # @param [Integer,Wx::Enum,Wx::Window,Wx::MenuItem,Wx::ToolBarTool,Wx::Timer] id window/control id
  # @param [String,Symbol,Method,Proc] meth (name of) method or handler proc
  # @yieldparam [Wx::PG::PropertyGridEvent] event the event to handle
  def evt_pg_page_changed(id, meth = nil, &block) end

  # @!endgroup

end
