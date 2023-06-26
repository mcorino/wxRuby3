
module Wx::PRT

  class PrinterDC < Wx::DC

    # Executes the given block providing a temporary (printer) dc as
    # it's single argument.
    # @param [Wx::PRT::PrintData] print_data print_data defining the print settings
    # @yieldparam [Wx::PrinterDC] dc the PrinterDC instance to paint on
    # @return [Object] result of the block
    def self.draw_on(win) end

  end

  class PostScriptDC < Wx::DC

    # Executes the given block providing a temporary (postscript) dc as
    # it's single argument.
    # @param [Wx::PRT::PrintData] print_data print_data defining the print settings
    # @yieldparam [Wx::PostScriptDC] dc the PostScriptDC instance to paint on
    # @return [Object] result of the block
    def self.draw_on(win) end

  end

end
