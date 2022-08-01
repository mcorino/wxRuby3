# Base class for all events
class Wx::Event
  # Get the Wx id, not Ruby's deprecated Object#id
  alias :id :get_id
end
