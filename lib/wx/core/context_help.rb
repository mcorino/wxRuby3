# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

module Wx

  class << self

    define_method :ContextHelp do |window = nil|

      context_help(window)

    end

  end

end
