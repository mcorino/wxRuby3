# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


class Wx::ColourDialog

  # Returns (a copy of) the colour data of the dialog.
  # @return [Wx::ColourData] colour data copy
  def get_colour_data; end
  alias :colour_data :get_colour_data

  # Updates the colour data for the dialog.
  # @param [Wx::ColourData] clr_data the colour data to update the dialog with
  # @return [void]
  def set_colour_data(clr_data); end
  alias :colour_data= :set_colour_data

end
