# Wx::HTML sub package for wxRuby3
# Copyright (c) M.J.N. Corino, The Netherlands

#require_relative './ext'
require_relative './events/evt_list'
require_relative './keyword_defs'
require_relative './htmlwindow'
require_relative './htmlhelpcontroller'
require_relative './simple_html_listbox'

Wx::Dialog.setup_dialog_functors(Wx::HTML)
