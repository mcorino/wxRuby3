# Class for automatically managing layouts
class Wx::Sizer
  # Generic method to add items, supporting positional and named
  # arguments
  ADD_ITEM_PARAMS = [ Wx::Parameter[ :index, -1 ], 
                      Wx::Parameter[ :proportion, 0 ],
                      Wx::Parameter[ :flag, 0 ],
                      Wx::Parameter[ :border, 0 ],
                      Wx::Parameter[ :user_data, nil ] ]
  
  def add_item(item, *mixed_args)

    begin
      args = Wx::args_as_list(ADD_ITEM_PARAMS, *mixed_args)
    rescue => err
      err.set_backtrace(caller)
      Kernel.raise err
    end

    full_args = []

    # extract the width and the height in the case of a spacer
    # defined as an array
    if item.kind_of?(Array)
      Kernel.raise ArgumentError,
        "Invalid Sizer specification : [width, height] expected" if item.size != 2
      full_args << item[0] << item[1]
    else
      full_args << item
    end

    # update the full arguments list with the optional arguments (except index)
    idx = args.shift
    full_args.concat(args)

    # Call add to append if default position
    if idx == -1
      add(*full_args)
    else
      insert(idx, *full_args)
    end
  end
end
