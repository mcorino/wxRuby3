# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

# Wx::RBN sub package for wxRuby3

require_relative './events/evt_list'

if Wx.at_least_wxwidgets?('3.3.4')
  # add event handlers missing from XML docs
  class Wx::EvtHandler
    # from wxBackstage
    self.register_event_type EventType[
                               'evt_backstage_clicked', 1,
                               Wx::RBN::EVT_BACKSTAGE_CLICKED,
                               Wx::NotifyEvent
                             ] if Wx::RBN.const_defined?(:EVT_BACKSTAGE_CLICKED)
    # from wxBackstageItemList
    self.register_event_type EventType[
                               'evt_backstage_item_clicked', 1,
                               Wx::RBN::EVT_BACKSTAGE_ITEM_CLICKED,
                               Wx::CommandEvent
                             ] if Wx::RBN.const_defined?(:EVT_BACKSTAGE_ITEM_CLICKED)
  end
end
