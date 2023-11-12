# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx

  module PRT

    class PrintDialogData

      # Returns (a copy of) the print data.
      # @return [Wx::PRT::PrintData] print data copy
      def get_print_data; end
      alias :print_data :get_print_data

    end

  end

end
