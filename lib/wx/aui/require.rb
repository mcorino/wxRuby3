# Wx::AUI sub package for wxRuby3
# Copyright (c) M.J.N. Corino, The Netherlands

#require_relative './ext'
require_relative './events/evt_list'
require_relative './auimanager'
require_relative './auinotebook'

Wx::Dialog.setup_dialog_functors(Wx::AUI)
