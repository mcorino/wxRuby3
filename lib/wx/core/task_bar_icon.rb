
class Wx::TaskBarIcon

  wx_set_icon = self.instance_method(:set_icon)
  define_method(:set_icon) do |*args|
    icon, tooltip = args
    wx_set_icon.bind(self).call(Wx.bitmap_to_bundle(icon), tooltip)
  end
end
