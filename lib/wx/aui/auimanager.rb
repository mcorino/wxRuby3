# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

module Wx
  module AUI

    class AuiManager

      wx_each_pane = instance_method(:each_pane)
      wx_redefine_method(:each_pane) do |&block|
        if block
          wx_each_pane.bind(self).call(&block)
        else
          ::Enumerator.new { |y| wx_each_pane.bind(self).call { |p| y << p } }
        end
      end

      def get_all_panes
        each_pane.to_a
      end
      alias :all_panes :get_all_panes

      unless Wx::EvtHandler.event_type_for_name(:evt_aui_find_manager)
        # missing from XML API refs
        Wx::EvtHandler.register_event_type Wx::EvtHandler::EventType[
                                             'evt_aui_find_manager', 0,
                                             Wx::AUI::EVT_AUI_FIND_MANAGER,
                                             Wx::AUI::AuiManagerEvent
                                           ] if Wx::AUI.const_defined?(:EVT_AUI_FIND_MANAGER)
      end
    end

    if Wx.at_least_wxwidgets?('3.3.0')

      class AuiTabLayoutInfo < AuiDockLayoutInfo

        alias :pages :get_pages
        alias :pages= :set_pages

      end

      class AuiDeserializer

        wx_initialize = instance_method(:initialize)
        wx_redefine_method(:initialize) do |manager|
          wx_initialize.bind(self).call(manager)
          @manager = manager # prevent GC for lifetime of deserializer
        end

      end

    end

  end
end
