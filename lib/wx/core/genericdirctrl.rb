# Bottom-up implementation of a Directory lister
class Wx::GenericDirCtrl
  module DirCtrlTree 
    # The TreeCtrl contained in a GenericDirCtrl already has C++ data
    # associated with the items. If these are returned to Ruby crashes
    # will result. So this module sets the TreeCtrl to return the path
    # string.
    def get_item_data(tree_id)
      root_id = get_root_item
      return "" if tree_id == root_id

      path = item_text(tree_id)
      while tree_id = item_parent(tree_id) and tree_id != root_id
        path = item_text(tree_id) + "/#{path}" 
      end
      unless Wx::PLATFORM == 'WXMSW'
        path = "/" + path
      end
      path
    end

    alias :get_item_path :get_item_data

    # Not allowed
    def set_item_data(tree_id, data)
      Kernel.raise "Item data cannot be set for a GenericDirCtrl's Tree"
    end
  end
  
  wx_get_tree_ctrl = instance_method(:get_tree_ctrl)
  define_method(:get_tree_ctrl) do 
    tree = wx_get_tree_ctrl.bind(self).call
    tree.extend(DirCtrlTree)
    tree
  end
end
