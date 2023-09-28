# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx

  class BusyInfo

    # @overload busy(message, parent=nil)
    #   Shows busy info window with message, blocks event handling and calls the given block
    #   passing the BusyInfo instance as argument.
    #   @param [String] message
    #   @param [Wx::Window,nil] parent
    #   @yieldparam [Wx::BusyInfo] bi BusyInfo instance
    # @overload busy(busy_info)
    #   Shows busy info window according to busy_info settings, blocks event handling and calls the given block
    #   passing the BusyInfo instance as argument.
    #   @param [Wx::BusyInfoFlags] busy_info
    #   @yieldparam [Wx::BusyInfo] bi BusyInfo instance
    def self.busy(*args) end

  end

end
