# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx

  class DatePickerCtrl < Control

    # If the control had been previously limited to a range of dates using #set_range, returns the lower and upper bounds of this range.
    #
    # If no range is set (or only one of the bounds is set), dt1 and/or dt2 are set to be invalid.
    #
    # Notice that when using a native MSW implementation of this control the lower range is always set, even
    # if #set_range hadn't been called explicitly, as the native control only supports dates later than year 1601.
    # @return [Array(Time, Time),nil] a set with the lower and upper range limit or nil if no range previously set
    def get_range; end

  end

end
