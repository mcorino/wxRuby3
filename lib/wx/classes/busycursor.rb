# Emulates the wxWidgets BusyCursor class, by providing a scope within
# which a busy cursor will be shown
class Wx::BusyCursor
  # Only one class method, optionally accepting a cursor that should be
  # shown, defaulting to an hour glass cursor.
  def self.busy(cursor = Wx::HOURGLASS_CURSOR)
    Wx::begin_busy_cursor(cursor)
    yield
  ensure
    Wx::end_busy_cursor
  end
end
