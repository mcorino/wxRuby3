# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

module Wx

  class TopLevelWindow

    # create PersistentObject for toplevel windows (incl. Dialog and Frame)
    def create_persistent_object
      PersistentTLW.new(self)
    end

    # fix missing method on some platforms/wxw versions
    unless method_defined? :enable_full_screen_view
      def enable_full_screen_view
        false
      end
    end

  end

end
