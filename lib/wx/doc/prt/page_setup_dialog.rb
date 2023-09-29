# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


class Wx::PRT::PageSetupDialog

  # Returns (a copy of) the page setup data of the dialog.
  # @return [Wx::PRT::PageSetupDialogData] page setup data copy
  def get_page_setup_data; end
  alias :page_setup_data :get_page_setup_data

  # Updates the page setup data for the dialog.
  # @param [Wx::PRT::PageSetupDialogData] setup_data the page setup data to update the dialog with
  # @return [void]
  def set_page_setup_data(setup_data); end
  alias :page_setup_data= :set_page_setup_data

end
