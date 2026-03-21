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
      wx_redefine_method :use_config do |cfg, *args|
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

    class << self

      define_method :HtmlModalHelp do |parent, helpFile, topic, style = Wx::HTML::HF_DEFAULT_STYLE|

        # Force some mandatory styles
        style = style | Wx::HTML::HF_DIALOG | Wx::HTML::HF_MODAL

        controller = Wx::HTML::HtmlHelpController.new(style, parent)
        controller.init(helpFile)

        if topic.empty?
          controller.display_contents
        else
          controller.display_section(topic)
        end

      end

    end

  end

end
