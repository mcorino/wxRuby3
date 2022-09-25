# Device Context to paint on a window outside an on_paint handler. It is
# recommended that PaintDC is used in preference to this class.
class Wx::ClientDC
  # This class should not be instantiated directly in wxRuby; it should
  # always be used via Window#paint, which takes a block receiving the
  # DC. This ensures that the DC is cleaned up at the correct time,
  # avoiding errors and segfaults on exit.
  define_method(:initialize) do | *args |
    Kernel.raise RuntimeError,
                 "Do not instantiate ClientDC directly; use Window#paint",
                 caller[1..-1]
  end
end
