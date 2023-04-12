# Frame that displays a print preview
class Wx::PRT::PreviewFrame
  # a PreviewFrame has a preview associated with it that must be
  # protected from Ruby's GC. However, there is no C++ method to access
  # the Wx::PRT::PrintPreview (only a protected member), so instead we have
  # to assign it to an instance variable so it is marked correctly when
  # the frame displaying it is marked.
  wx_init = self.instance_method(:initialize)
  define_method(:initialize) do | *args |
    wx_init.bind(self).call(*args)
    @__preview = args[0]
  end
end

module Wx::PRT
  # internally used Canvas derivatives which we do not need to
  # publicly expose; these declarations prevent warnings from
  # the generic wxWindow* wrapping code
  PreviewCanvas = Wx::Panel
  PreviewControlBar = Wx::Panel
end
