# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.


module Wx

  class StandardPaths

    class << self

      wx_get = instance_method :get
      wx_redefine_method :get do
        # cache the global singleton
        @instance ||= wx_get.bind(self).call
      end

    end

  end

end
