
module Wx

  class Event

    # Constructor
    # @param [Integer] evt_type
    # @param [Integer] id
    # @param [Wx::EventPropagation] prop_level
    def initialize(evt_type = Wx::EVT_NULL, id = 0, prop_level = Wx::EVENT_PROPAGATE_NONE) end

  end

end
