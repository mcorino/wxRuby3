class Wx::TextCtrl
  # Fix position_to_xy so it returns a two-element array - the internal
  # version returns a three-element array with a Boolean that doesn't
  # really make sense in Ruby
  wx_position_to_xy = instance_method(:position_to_xy)
  define_method(:position_to_xy) do | pos |
    retval, x, y = wx_position_to_xy.bind(self).call(pos)
    if retval
      return [x, y]
    else
      return nil
    end
  end
end
