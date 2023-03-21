
class Wx::RBN::RibbonToolBar

  def tool_client_data
    @tool_client_data ||= {}
  end
  private :tool_client_data

  def set_tool_client_data(tool, data)
    tool_client_data[tool] = data
  end

  def get_tool_client_data(tool)
    tool_client_data[tool]
  end

end
