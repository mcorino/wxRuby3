
class Wx::Aui::AuiManager

  # Yield each pane to the given block.
  # @yieldparam [Wx::Aui::AuiPaneInfo] pane the Aui pane info yielded
  def each_pane; end

  # Returns an array of all panes managed by the frame manager.
  # @return [Array<Wx::Aui::AuiPaneInfo>] all managed panes
  def get_all_panes; end
  alias_method :all_panes, :get_all_panes
end
