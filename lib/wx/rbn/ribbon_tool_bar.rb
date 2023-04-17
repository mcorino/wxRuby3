
class Wx::RBN::RibbonToolBar

  def tool_client_data_store
    @tool_client_data ||= {}
  end
  private :tool_client_data_store

  def set_tool_client_data(tool, data)
    tool_client_data_store[tool] = data
  end

  def get_tool_client_data(tool)
    tool_client_data_store[tool]
  end
  alias :tool_client_data :get_tool_client_data

end
