# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# 
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

module Wx

  # get the user selection as a string
  def self.get_single_choice(message,
                             caption,
                             choices,
                             parent = nil,
                             initial_selection: 0,
                             pos:  Wx::DEFAULT_POSITION)
    dialog = Wx::SingleChoiceDialog.new(parent, message, caption, choices, Wx::CHOICEDLG_STYLE, pos)

    dialog.selection = initial_selection
    return dialog.show_modal == Wx::ID_OK ? dialog.get_string_selection : ''
  end

  # get the user selection as an index
  def self.get_single_choice_index(message,
                                   caption,
                                   choices,
                                   parent = nil,
                                   initial_selection: 0,
                                   pos:  Wx::DEFAULT_POSITION)
    dialog = Wx::SingleChoiceDialog.new(parent, message, caption, choices, Wx::CHOICEDLG_STYLE, pos)

    dialog.selection = initial_selection
    return dialog.show_modal == Wx::ID_OK ? dialog.get_selection : -1
  end

  # return an array with the indices of the chosen items, it will be empty
  # if no items were selected or Cancel was pressed
  def self.get_selected_choices(message,
                                caption,
                                choices,
                                parent = nil,
                                initial_selections: [],
                                pos:  Wx::DEFAULT_POSITION)
    dialog = Wx::MultiChoiceDialog.new(parent, message, caption, choices, Wx::CHOICEDLG_STYLE, pos)

    # call this even if selections array is empty and this then (correctly)
    # deselects the first item which is selected by default
    dialog.selections = initial_selections

    if dialog.show_modal != Wx::ID_OK
      return nil
    end

    dialog.get_selections
  end

end
