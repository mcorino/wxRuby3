# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


class Wx::RTC::RichTextPrinting

  # Returns (a copy of) the print data.
  # @return [Wx::PRT::PrintData] print data copy
  def get_print_data; end
  alias :print_data :get_print_data

  # Returns (a copy of) the page setup data.
  # @return [Wx::PRT::PageSetupDialogData] page setup data copy
  def get_page_setup_data; end
  alias :page_setup_data :get_page_setup_data

end
