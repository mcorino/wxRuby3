# Frame that displays a print preview
class Wx::Print::PreviewFrame
  # a PreviewFrame has a preview associated with it that must be
  # protected from Ruby's GC. However, there is no C++ method to access
  # the Wx::PrintPreview (only a protected member), so instead we have
  # to assign it to an instance variable so it is marked correctly when
  # the frame displaying it is marked.
  wx_init = self.instance_method(:initialize)
  define_method(:initialize) do | *args |
    wx_init.bind(self).call(*args)
    @__preview = args[0]
  end
end
