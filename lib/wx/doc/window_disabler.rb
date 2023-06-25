
class Wx::WindowDisabler

  # Disables all top level windows of the application (maybe with the exception of one of them) in
  # and enables them back after the given block has returned.
  # @param [Wx::Window,nil] to_skip window to exclude from disabling
  # @return [void]
  def self.disable(to_skip = nil) end

end
