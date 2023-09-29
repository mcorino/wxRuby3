# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

# Wx::STC sub package for wxRuby3

require_relative './events/evt_list'
require_relative './keyword_defs'

Wx::Dialog.setup_dialog_functors(Wx::STC)
