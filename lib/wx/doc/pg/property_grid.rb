
module Wx::PG

  class PropertyGrid

    # Return a registered property editor (either custom or standard)
    # @param [String] name Property editor class name
    # @return [Wx::PG::PGEditor,nil] Registered property editor (or nil if not found).
    def self.get_editor_class(name); end

    # Return a registered standard (wx) property editor.
    # @param [String] name Property editor class name
    # @return [Wx::PG::PGEditor,nil] Registered property editor (or nil if not found).
    def self.get_standard_editor_class(name); end

    # Forwards to DoRegisterEditorClass with class name of provided property editor.
    # @param editor [Wx::PG::PGEditor]
    # @return [Wx::PG::PGEditor]
    def self.register_editor_class(editor); end

    # Generates position for a widget editor dialog box.
    #
    # @param [Wx::PG::PGProperty] p Property the editor dialog is to be shown for.
    # @param [Wx::Size] sz Size of the editor dialog to be shown.
    # @return [Wx::Point] Best position to show the dialog.
    def get_good_editor_dialog_position(p, sz) end

  end

end
