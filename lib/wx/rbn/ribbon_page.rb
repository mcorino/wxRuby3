
class Wx::RBN::RibbonPage

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
