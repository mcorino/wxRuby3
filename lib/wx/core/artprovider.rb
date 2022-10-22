# Class which can supply icons and bitmaps
class Wx::ArtProvider
  # Keep a note of supplied ArtProviders to prevent them being GC'd
  @__art_provs = []

  class << self 
    wx_push_back = instance_method(:push_back)
    define_method(:push_back) do | art_prov |
      wx_push_back.bind(self).call(art_prov)
      @__art_provs.unshift(art_prov)
    end

    wx_pop = instance_method(:pop)
    define_method(:pop) do
      wx_pop.bind(self).call
      @__art_provs.pop
    end

    wx_push = instance_method(:push)
    define_method(:push) do | art_prov |
      wx_push.bind(self).call(art_prov)
      @__art_provs.push(art_prov)
    end

    wx_remove = instance_method(:remove)
    define_method(:remove) do | art_prov |
      wx_push.bind(self).call(art_prov)
      @__art_provs.delete(art_prov)
    end
  end
end
