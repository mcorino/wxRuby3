# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx

  class Choice < ControlWithItems

    alias :get_item_data :get_client_object

    alias :set_item_data :set_client_object

  end

end
