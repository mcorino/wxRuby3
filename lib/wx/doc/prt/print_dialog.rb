# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


class Wx::PRT::PrintDialog

  # Returns (a copy of) the print data of the dialog.
  # @return [Wx::PRT::PrintData] print data copy
  def get_print_data; end
  alias :print_data :get_print_data

  # Updates the print data for the dialog.
  # @param [Wx::PRT::PrintData] prt_data the print data to update the dialog with
  # @return [void]
  def set_print_data(prt_data); end
  alias :print_data= :set_print_data

  # Returns (a copy of) the print dialog data of the dialog.
  # @return [Wx::PRT::PrintDialogData] print dialog data copy
  def get_print_dialog_data; end
  alias :print_dialog_data :get_print_dialog_data

  # Updates the print dialog data for the dialog.
  # @param [Wx::PRT::PrintDialogData] prt_data the print dialog data to update the dialog with
  # @return [void]
  def set_print_dialog_data(prt_data); end
  alias :print_dialog_data= :set_print_dialog_data

end
