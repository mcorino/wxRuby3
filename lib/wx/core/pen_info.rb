# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# 
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

class Wx::PenInfo

  # make Wx::PenInfo#dashes return self
  wx_dashes = instance_method :dashes
  wx_redefine_method :dashes do |*args|
    wx_dashes.bind(self).call(*args)
    self
  end

end
