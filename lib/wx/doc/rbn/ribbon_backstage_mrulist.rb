# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx

  module RBN

    class BackstageMRUList

      # Sets a callback object (Method, Proc, block, lambda) that returns the icon to show for a file given the file name.
      # By default, a standard file icon is used for all files.
      #
      # @param [Method,Proc] provider icon provider method or proc accepting a single string argument; to be supplied when no block is given
      # @yieldparam [::String] path the file path for which to return a matching bitmap/icon
      def set_icon_provider(provider=nil, &block); end

    end

  end

end
