# Wx global methods
#
# Documentation stubs for global Wx methods


module Wx

  # @!group Logging methods

  # Log a Wx message with the given logging level to the current Wx log output
  # @param lvl  [Integer] logging level (like {Wx::LOG_Message})
  # @param fmt  [String]  message (formatting) string
  # @param args [Array<Object>] optional message arguments
  # @return [nil]
  def self.log_generic(lvl, fmt, *args) end

  # Log a Wx low priority informational message to the current Wx log output
  # @param fmt  [String]  message (formatting) string
  # @param args [Array<Object>] optional message arguments
  # @return [nil]
  def self.log_info(fmt, *args) end

  # Log a Wx Informational message to the current Wx log output
  # @param fmt  [String]  message (formatting) string
  # @param args [Array<Object>] optional message arguments
  # @return [nil]
  def self.log_message(fmt, *args) end

  # Log a Wx Error message to the current Wx log output
  # @param fmt  [String]  message (formatting) string
  # @param args [Array<Object>] optional message arguments
  # @return [nil]
  def self.log_error(fmt, *args) end

  # Log a Wx Warning message to the current Wx log output
  # @param fmt  [String]  message (formatting) string
  # @param args [Array<Object>] optional message arguments
  # @return [nil]
  def self.log_warning(fmt, *args) end

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

  # Log a Wx verbose informational message to the current Wx log output
  # (needs explicit activation to be shown)
  # @param fmt  [String]  message (formatting) string
  # @param args [Array<Object>] optional message arguments
  # @return [nil]
  def self.log_verbose(fmt, *args) end

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

  # @return [Integer] One of {Wx::YES}, {Wx::NO}, {Wx::CANCEL}, {Wx::OK} or {Wx::HELP}
  def self.message_box(message, caption = 'Message', style = Wx::OK,
                       parent = nil, x = Wx::DEFAULT_COORD, y = Wx::DEFAULT_COORD) end

  # @return [Array<Integer>] Selected choices
  def self.get_selected_choices(message, caption, n, choices,
                                parent = nil, x = Wx::DEFAULT_COORD, y = Wx::DEFAULT_COORD,
                                centre = true, width = Wx::CHOICE_WIDTH, height = Wx::CHOICE_HEIGHT) end

  # Do not use if -1 is a valid number to enter.
  # @return [Integer] Entered number or -1 if cancelled
  def self.get_number_from_user(message, prompt, caption,
                                value, min = 0, max = 100,
                                parent = nil, pos = Wx::DEFAULT_POSITION) end

  # @return [String] Entered text.
  def self.get_text_from_user(message, caption = 'Input Text', default_value = '', parent = nil) end

  # @return [String] Entered text.
  def self.get_password_from_user(message, caption = 'Enter Password', default_value = '', parent = nil) end

  # @!endgroup

end
