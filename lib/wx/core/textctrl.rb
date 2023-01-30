
class Wx::TextCtrl
  wx_op_append = instance_method :<<
  define_method :<< do |o|
    wx_op_append.bind(self).call(o)
    self
  end
end
