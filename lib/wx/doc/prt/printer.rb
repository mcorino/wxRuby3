# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


class Wx::PRT::Printer

  # Returns (a copy of) the print dialog data of the printer.
  # @return [Wx::PRT::PrintDialogData] print dialog data copy
  def get_print_dialog_data; end
  alias :print_dialog_data :get_print_dialog_data

  # Updates the print dialog data for the printer.
  # @param [Wx::PRT::PrintDialogData] prt_data the print dialog data to update the printer with
  # @return [void]
  def set_print_dialog_data(prt_data); end
  alias :print_dialog_data= :set_print_dialog_data

end
