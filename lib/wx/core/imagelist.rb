
class Wx::ImageList

  # provide seamless support for adding icons on all platforms
  wx_add = instance_method :add
  define_method :add do |*args|
    if Wx::Icon === args.first
      args[0] = args.first.to_bitmap
    end
    wx_add.bind(self).call(*args)
  end

  alias :<< :add
end
