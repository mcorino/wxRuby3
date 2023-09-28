# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

module Wx::RBN
  # TODO - set default for OSX art provider when implemented
  if Wx::PLATFORM == 'WXMSW'
    RibbonDefaultArtProvider = RibbonMSWArtProvider
  else
    RibbonDefaultArtProvider = RibbonAUIArtProvider
  end
end
