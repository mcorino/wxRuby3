# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

# Wx::RTC sub package for wxRuby3

require_relative './ext'
require_relative './events/evt_list'
require_relative './keyword_defs'
require_relative './rich_text_ctrl'
require_relative './richtext_buffer'
require_relative './rich_text_composite_object'
require_relative './rich_text_paragraph'
require_relative './richtext_formatting_dialog'
require_relative './symbol_picker_dialog'
require_relative './richtext_style_organiser_dialog'

Wx::Dialog.setup_dialog_functors(Wx::RTC)
