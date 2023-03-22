
class Wx::RBN::RibbonControl

  # manage RibbonArtProvider for GC
  wx_set_art_provider = instance_method :set_art_provider
  define_method :set_art_provider do |prov|
    @art_provider = nil # clear any previously set
    wx_set_art_provider.bind(self).call(prov)
    if prov != get_ancestor_ribbon_bar.get_art_provider
      @art_provider = prov # keep non-wx-managed provider safe
    end
  end
  alias :art_provider= :set_art_provider

end

module Wx
  module RBN
    # internally used specialized ribbon control without public exposure
    # window* to these controls will surface (with the specialized wxWidgets
    # class name) however so make them known to wxRuby mapped to the generic
    # RibbonControl class
    RibbonPageScrollButton = RibbonControl
  end
end
