# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

module Wx

  module HTML

    class HtmlHelpController

      def self.instance(*args)
        @instance ||= new(*args)
      end

      # cache any explicitly assigned config for GC protection
      wx_use_config = instance_method(:use_config)
      define_method :use_config do |cfg, *args|
        @configuration = cfg
        if get_help_window
          # also set config var for any associated help window (as wxWidgets propagates it too)
          # so the instance remains GC protected whether or not the help window is destructed before
          # or after the controller
          get_help_window.instance_variable_set('@configuration', cfg)
        end
        wx_use_config.bind(self).call(cfg, *args)
      end

    end

  end

end
