
class Wx::Aui::AuiManager

  # Yield each pane to the given block.
  # @yieldparam [Wx::Aui::AuiPaneInfo] pane the Aui pane info yielded
  def each_pane; end

  alias_method :all_panes, :get_all_panes
end
