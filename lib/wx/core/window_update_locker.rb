# Emulates the wxWidgets WindowUpdateLocker class, by providing a scope within
# which window can be updated without refreshing
class Wx::WindowUpdateLocker
  # Only one class method accepting a window that will be
  # frozen while the block is executed
  def self.update(win)
    win.freeze
    yield
  ensure
    win.thaw
  end
end
