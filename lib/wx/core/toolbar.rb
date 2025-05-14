# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# 
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

# A set of buttons and controls attached to one edge of a Wx::Frame

class Wx::ToolBar
  # Generic method to add items, supporting positional and named
  # arguments
  ADD_ITEM_PARAMS = [ 
                      Wx::Parameter[ :bitmap2, Wx::NULL_BITMAP ],
                      Wx::Parameter[ :position, -1 ], 
                      Wx::Parameter[ :id, -1 ],
                      Wx::Parameter[ :label, "" ], 
                      Wx::Parameter[ :kind, Wx::ItemKind::ITEM_NORMAL ],
                      Wx::Parameter[ :short_help, "" ], 
                      Wx::Parameter[ :long_help, "" ], 
                      Wx::Parameter[ :client_data, nil ] ]
  
  def add_item(bitmap1, *args, **kwargs)

    begin
      args = Wx::args_as_list(ADD_ITEM_PARAMS, *args, **kwargs)
    rescue => err
      err.set_backtrace(caller)
      Kernel.raise err
    end

    bitmap2 = args.shift

    pos = args.shift
    args.insert(2, bitmap1)
    args.insert(3, bitmap2)

    # Call add_tool to append if default position
    if pos == -1
      add_tool(*args)
    else
      insert_tool(pos, *args)
    end
  end
end
