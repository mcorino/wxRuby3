# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

module Wx

  module DVW
  
    class DataViewModel
  
      # manage GC marking for added notifiers
      
      def notifiers
        @notifiers ||= []
      end
      protected :notifiers
      
      wx_add_notifier = instance_method(:add_notifier)
      wx_redefine_method(:add_notifier) do | notifier |
        notifiers << notifier
        wx_add_notifier.bind(self).call(notifier)
      end

      wx_remove_notifier = instance_method(:remove_notifier)
      wx_redefine_method(:remove_notifier) do | notifier |
        wx_remove_notifier.bind(self).call(notifier)
        notifiers.delete(notifier)
        nil
      end
      
    end

  end

end
