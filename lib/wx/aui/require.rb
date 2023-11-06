# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

# Wx::AUI sub package for wxRuby3

#require_relative './ext'
require_relative './events/evt_list'
require_relative './auimanager'
require_relative './auinotebook'
require_relative './auifloatframe'
require_relative './aui_tab_ctrl'

Wx::Dialog.setup_dialog_functors(Wx::AUI)
