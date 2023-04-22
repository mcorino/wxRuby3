
class Wx::PenInfo

  # make Wx::PenInfo#dashes return self
  wx_dashes = instance_method :dashes
  define_method :dashes do |*args|
    wx_dashes.bind(self).call(*args)
    self
  end

end
