# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# 
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

# Class which can supply icons and bitmaps

class Wx::ArtProvider
  # Keep a note of supplied ArtProviders to prevent them being GC'd
  @__art_provs = []

  class << self 
    wx_push_back = instance_method(:push_back)
    wx_redefine_method(:push_back) do | art_prov |
      wx_push_back.bind(self).call(art_prov)
      @__art_provs.push(art_prov)
    end

    wx_pop = instance_method(:pop)
    wx_redefine_method(:pop) do
      wx_pop.bind(self).call
      @__art_provs.pop
    end

    wx_push = instance_method(:push)
    wx_redefine_method(:push) do | art_prov |
      wx_push.bind(self).call(art_prov)
      @__art_provs.unshift(art_prov)
    end

    wx_delete = instance_method(:delete)
    wx_redefine_method(:delete) do | art_prov |
      wx_delete.bind(self).call(art_prov)
      @__art_provs.delete(art_prov)
    end
  end
end
