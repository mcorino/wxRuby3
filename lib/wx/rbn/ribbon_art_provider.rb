

module Wx::RBN
  # TODO - set default for OSX art provider when implemented
  if Wx::PLATFORM == 'WXMSW'
    RibbonDefaultArtProvider = RibbonMSWArtProvider
  else
    RibbonDefaultArtProvider = RibbonAUIArtProvider
  end
end
