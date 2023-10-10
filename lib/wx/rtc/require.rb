# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

# Wx::RTC sub package for wxRuby3

require_relative './ext'
require_relative './events/evt_list'
require_relative './keyword_defs'
require_relative './richtext_buffer'

Wx::Dialog.setup_dialog_functors(Wx::RTC)
