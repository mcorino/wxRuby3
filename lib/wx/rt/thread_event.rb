# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
#

module Wx

  Wx::EvtHandler.register_event_type Wx::EvtHandler::EventType[
                                       'evt_thread', 1,
                                       Wx::RT::EVT_THREAD,
                                       Wx::RT::ThreadEvent
                                     ]

end
