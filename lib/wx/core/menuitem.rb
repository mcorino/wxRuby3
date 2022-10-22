# An individual item within a frame or popup menu
class Wx::MenuItem
  # Get the Wx id, not Ruby's deprecated Object#id
  alias :id :get_id
  # In case a more explicit option is preferred.
  alias :wx_id :get_id
end
