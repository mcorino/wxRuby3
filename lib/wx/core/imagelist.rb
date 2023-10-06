# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# 
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

class Wx::ImageList

  # provide seamless support for adding icons on all platforms
  wx_add = instance_method :add
  define_method :add do |*args|
    if Wx::PLATFORM == 'WXMSW' && args.size == 1 && Wx::Icon === args.first
      args[0] = args.first.to_bitmap
    end
    wx_add.bind(self).call(*args)
  end

  alias :<< :add
end
