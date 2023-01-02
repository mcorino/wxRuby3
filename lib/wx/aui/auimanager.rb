
class Wx::Aui::AuiManager
  def get_all_panes
    ::Enumerator.new { |y| each_pane { |p| y << p } }
  end
end
