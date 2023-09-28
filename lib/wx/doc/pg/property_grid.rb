# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


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
    # @param [Wx::PG::PGProperty] p Property the editor dialog is to be shown for.
    # @param [Wx::Size] sz Size of the editor dialog to be shown.
    # @return [Wx::Point] Best position to show the dialog.
    def get_good_editor_dialog_position(p, sz) end
    alias :good_editor_dialog_position :get_good_editor_dialog_position

    # Returns current active primary editor control or nil
    # @return [Wx::Window]
    def get_primary_editor; end
    alias :primary_editor :get_primary_editor

    # Returns current active secondary editor control or nil
    # @return [Wx::Window, nil]
    def get_editor_control_secondary; end
    alias :editor_control_secondary :get_editor_control_secondary

    # Returns rectangle that fully contains properties between and including
    # first and last. Rectangle is in virtual scrolled window coordinates.
    # @param first [Wx::PG::PGProperty] first property
    # @param last [Wx::PG::PGProperty] last property
    # @return [Wx::Rect]
    def get_property_rect(first, last) end
    alias :property_rect :get_property_rect

  end

end
