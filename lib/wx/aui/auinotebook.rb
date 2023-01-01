# Advanced User Interface Notebook - draggable panes etc
class Wx::Aui::AuiNotebook
  # Convenience method for iterating pages
  def each_page
    0.upto(get_page_count - 1) do | i |
      yield get_page(i)
    end
  end
end
