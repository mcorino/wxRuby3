# Wx::PRT sub package for wxRuby3
# Copyright (c) M.J.N. Corino, The Netherlands

require_relative './keyword_defs'
require_relative './previewframe'
require_relative './page_setup_dialog'

Wx::Dialog.setup_dialog_functors(Wx::PRT)
