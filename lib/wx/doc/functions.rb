# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.


# Wx global methods
#
# Documentation stubs for global Wx methods
# :startdoc:



module Wx

  # @!group Logging methods

  # Log a Wx message with the given logging level to the current Wx log output
  # @param lvl  [Integer] logging level (like {Wx::LOG_Message})
  # @param fmt  [String]  message (formatting) string
  # @param args [Array<Object>] optional message arguments
  # @param filename [String] optional file name for log info
  # @param line [Integer] optional line number for log info
  # @param func [String] optional function name for log info
  # @param component [String] optional component name for log info
  # @return [void]
  def self.log_generic(lvl, fmt, *args, filename: nil, line: 0, func: nil, component: nil) end

  # Log a Wx low priority informational message to the current Wx log output
  # @param fmt  [String]  message (formatting) string
  # @param args [Array<Object>] optional message arguments
  # @param filename [String] optional file name for log info
  # @param line [Integer] optional line number for log info
  # @param func [String] optional function name for log info
  # @param component [String] optional component name for log info
  # @return [void]
  def self.log_info(fmt, *args, filename: nil, line: 0, func: nil, component: nil) end

  # Log a Wx Informational message to the current Wx log output
  # @param fmt  [String]  message (formatting) string
  # @param args [Array<Object>] optional message arguments
  # @param filename [String] optional file name for log info
  # @param line [Integer] optional line number for log info
  # @param func [String] optional function name for log info
  # @param component [String] optional component name for log info
  # @return [void]
  def self.log_message(fmt, *args, filename: nil, line: 0, func: nil, component: nil) end

  # Log a Wx Error message to the current Wx log output
  # @param fmt  [String]  message (formatting) string
  # @param args [Array<Object>] optional message arguments
  # @param filename [String] optional file name for log info
  # @param line [Integer] optional line number for log info
  # @param func [String] optional function name for log info
  # @param component [String] optional component name for log info
  # @return [void]
  def self.log_error(fmt, *args, filename: nil, line: 0, func: nil, component: nil) end

  # Log a Wx Warning message to the current Wx log output
  # @param fmt  [String]  message (formatting) string
  # @param args [Array<Object>] optional message arguments
  # @param filename [String] optional file name for log info
  # @param line [Integer] optional line number for log info
  # @param func [String] optional function name for log info
  # @param component [String] optional component name for log info
  # @return [void]
  def self.log_warning(fmt, *args, filename: nil, line: 0, func: nil, component: nil) end

  # Log a Wx verbose informational message to the current Wx log output
  # (needs explicit activation to be shown)
  # @param fmt  [String]  message (formatting) string
  # @param args [Array<Object>] optional message arguments
  # @param filename [String] optional file name for log info
  # @param line [Integer] optional line number for log info
  # @param func [String] optional function name for log info
  # @param component [String] optional component name for log info
  # @return [void]
  def self.log_verbose(fmt, *args, filename: nil, line: 0, func: nil, component: nil) end

  # Log a Wx debug message to the current Wx log output
  # @param fmt  [String]  message (formatting) string
  # @param args [Array<Object>] optional message arguments
  # @param filename [String] optional file name for log info
  # @param line [Integer] optional line number for log info
  # @param func [String] optional function name for log info
  # @param component [String] optional component name for log info
  # @return [void]
  def self.log_debug(fmt, *args, filename: nil, line: 0, func: nil, component: nil) end

  # Log a Wx Status message - this is directed to the status bar of the
  # specified Frame window, or the application main window if not specified.
  # Based on Wx::Widgets code in src/generic/logg.cpp, WxLogGui::DoLog
  # @overload log_status(win, fmt, *args)
  #   @param win [Wx::Frame] window to log to
  #   @param fmt  [String]  message (formatting) string
  #   @param args [Array<Object>] optional message arguments
  # @overload log_status(fmt, *args)
  #   @param fmt  [String]  message (formatting) string
  #   @param args [Array<Object>] optional message arguments
  # @return [nil]
  def self.log_status(fmt, *args) end

  # @!endgroup

  # @!group Other class methods

  # Returns the global app object
  # @return [Wx::App] the global app object
  def self.get_app; end

  # Returns the pointer address of the underlying C++ object as a hex
  # string - useful for debugging
  # @param obj [Object] wrapped object
  # @return [String] string with address in hex format
  def self.cpp_ptr_addr(obj) end

  # Converts a string XRC id into a Wx id
  # @param str [String] XRC id string
  # @return [Integer] Wx Id
  def self.xrcid(str) end

  def self.begin_busy_cursor(cursor) end
  def self.end_busy_cursor; end
  def self.bell; end
  def self.safe_yield(win = nil, only_if_needed = false) end

  # @!endgroup

  # @!group System information
  
  # @return [String]
  def self.get_email_address; end
  # @return [String]
  def self.get_host_name; end
  # @return [String]
  def self.get_full_host_name; end
  # @return [String]
  def self.get_user_id; end
  # @return [String]
  def self.get_user_name; end
  # @return [String]
  def self.get_home_dir; end
  
  # @!endgroup

  # @!group Mouse / keyboard information

  # @return [true,false]
  def self.get_key_state(key) end
  # @return [Wx::Window]
  def self.find_window_at_point(point) end
  # @return [Wx::Window]
  def self.get_active_window; end
  # @return [Wx::Point]
  def self.get_mouse_position; end
  # @return [Wx::MouseState]
  def self.get_mouse_state; end

  # @!endgroup

  # @!group Dialog shortcuts

  # @return [Array<Integer>] Selected choices
  def self.get_selected_choices(message, caption, choices,
                                parent = nil, x = Wx::DEFAULT_COORD, y = Wx::DEFAULT_COORD,
                                centre = true, width = Wx::CHOICE_WIDTH, height = Wx::CHOICE_HEIGHT) end

  # Pops up a file selector box.
  #
  # In Windows, this is the common file selector dialog. In X, this is a file selector box with the same functionality.
  # The path and filename are distinct elements of a full file pathname. If path is empty, the current directory will
  # be used. If filename is empty, no default filename will be supplied. The wildcard determines what files are
  # displayed in the file selector, and file extension supplies a type extension for the required filename. Flags may
  # be a combination of Wx::FD_OPEN, Wx::FD_SAVE, Wx::FD_OVERWRITE_PROMPT or Wx::FD_FILE_MUST_EXIST.
  #
  # @note Wx::FD_MULTIPLE can only be used with Wx::FileDialog and not here since this function only returns a single file name.
  #
  # Both the Unix and Windows versions implement a wildcard filter. Typing a filename containing wildcards (*, ?) in
  # the filename text item, and clicking on Ok, will result in only those files matching the pattern being displayed.
  # The wildcard may be a specification for multiple types of file with a description for each, such as:
  # <code>"BMP files (*.bmp)|*.bmp|GIF files (*.gif)|*.gif"</code>
  #
  # The application must check for an empty return value (the user pressed Cancel). For example:
  # <code>
  #   filename = Wx::file_selector("Choose a file to open")
  #   unless filename.empty?
  #     # work with the file
  #     ...
  #   end
  #   # else: cancelled by user
  # </code>
  # @return [String] selected file name
  def file_selector(message, default_path='', default_filename='', default_extension='', wildcard='',
                    flags=0, parent=nil, x=Wx::DEFAULT_COORD, y=Wx::DEFAULT_COORD) end

  # An extended version of {Wx::file_selector}.
  # @return [String] selected file name
  def file_selector_ex(message='Select a file', default_path='', default_filename='', indexDefaultExtension=nil,
                       wildcard='*', flags=0, parent=nil, x=Wx::DEFAULT_COORD, y=Wx::DEFAULT_COORD) end

  # Shows a file dialog asking the user for a file name for saving a file.
  # @see Wx::file_selector, Wx::FileDialog
  def load_file_selector(what,  extension, default_name='', parent=nil) end

  # Shows a file dialog asking the user for a file name for opening a file.
  # @see Wx::file_selector, Wx::FileDialog
  def save_file_selector(what, extension, default_name='', parent=nil) end

  # @!endgroup

  # @!group Managing stock IDs

  # Returns true if the ID is in the list of recognized stock actions
  # @param [Integer] id ID to check
  # @return [true,false]
  def is_stock_id(id) end

  # Returns true if the label is empty or label of a stock button with
  # given ID
  # @param [Integer] id ID to check
  # @param [String] label to check
  # @return [true,false]
  def is_stock_label(id, label) end

  STOCK_NOFLAGS = 0

  STOCK_WITH_MNEMONIC = 1

  STOCK_WITH_ACCELERATOR = 2

  STOCK_WITHOUT_ELLIPSIS = 4

  STOCK_FOR_BUTTON = STOCK_WITHOUT_ELLIPSIS | STOCK_WITH_MNEMONIC

  # Returns label that should be used for given id element.
  # @param [Integer] id	Given id of the wxMenuItem, wxButton, wxToolBar tool, etc.
  # @param [Integer] flags Combination of the elements of STOCK_xxx flags.
  # @return [String]
  def get_stock_label(id, flags = Wx::STOCK_WITH_MNEMONIC) end

  # Returns the accelerator that should be used for given stock UI element
  # (e.g. "Ctrl+X" for Wx::ID_CUT)
  # @param [Integer] id stock UI element ID
  # @return [Wx::AcceleratorEntry]
  def get_stock_accelerator(id) end

  STOCK_MENU = 0

  # Returns a help string for the given stock UI element and for the given "context".
  # @param [Integer] id stock UI element ID
  # @param [Integer] client context (currently only STOCK_MENU)
  # @return [String]
  def get_stock_help_string(id, client = Wx::STOCK_MENU) end

  # @!endgroup

end
