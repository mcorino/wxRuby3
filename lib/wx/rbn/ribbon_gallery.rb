
class Wx::RBN::RibbonGallery

  def item_client_data
    @item_client_data ||= {}
  end
  private :item_client_data

  def set_item_client_data(item, data)
    item_client_data[item] = data
  end

  def get_item_client_data(item)
    item_client_data[item]
  end

end
