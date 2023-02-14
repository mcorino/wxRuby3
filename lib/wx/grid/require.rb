# Wx::Grid sub package for wxRuby3
# Copyright (c) M.J.N. Corino, The Netherlands

#require_relative './ext'
require_relative './events/evt_list'
require_relative './keyword_defs'
require_relative './grid'

Wx::Dialog.setup_dialog_functors(Wx::GRID)
