# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

module Wx

  class PersistentWindowBase < PersistentObject

    alias :get :get_object

  end

  # class alias
  PersistentWindow = PersistentWindowBase

end
