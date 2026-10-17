# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

# Wx::RBN sub package for wxRuby3

require_relative './events/evt_list'

# add event handler missing from XML docs
class Wx::EvtHandler
  # from wxBackstage
  self.register_event_type EventType[
                             'evt_backstage_clicked', 1,
                             Wx::RBN::EVT_BACKSTAGE_CLICKED,
                             Wx::NotifyEvent
                           ] if Wx::RBN.const_defined?(:EVT_BACKSTAGE_CLICKED)
end
