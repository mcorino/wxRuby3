# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# 
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

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
