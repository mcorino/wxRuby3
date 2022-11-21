class Wx::HtmlWindow
  # imitate the in-built LoadFile method
  def load_file(file)
    set_page( File.read(file) )
  end
end
