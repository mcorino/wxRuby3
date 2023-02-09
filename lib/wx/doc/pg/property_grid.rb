
module Wx::PG

  class PropertyGrid

    # Generates position for a widget editor dialog box.
    #
    # @param [Wx::PG::PGProperty] p Property the editor dialog is to be shown for.
    # @param [Wx::Size] sz Size of the editor dialog to be shown.
    # @return [Wx::Point] Best position to show the dialog.
    def get_good_editor_dialog_position(p, sz) end

  end

end
