# Base class for all events
class Wx::Event
  # Get the Wx id, not Ruby's deprecated Object#id
  alias :id :get_id
end

module Wx
  # reduce mapping warnings for this unpublished event class
  NcPaintEvent = Wx::Event

  EvtHandler.register_event_type EvtHandler::EventType[
    'evt_nc_paint', 0,
    Wx::EVT_NC_PAINT,
    Wx::NcPaintEvent
  ]
end
