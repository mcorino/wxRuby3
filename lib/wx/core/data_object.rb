# Provide some default implementations of these to make life easier
class Wx::DataObject
  def get_preferred_format(direction)
    get_all_formats(direction).first
  end

  def get_format_count(direction)
    get_all_formats(direction).length
  end

  def get_data_size(format)
    get_data_here(format).size
  end
end
