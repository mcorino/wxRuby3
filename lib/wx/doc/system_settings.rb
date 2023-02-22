
class Wx::SystemSettings

  # Return the name of the current system appearance if available or empty string otherwise.
  #
  # This is currently only implemented for macOS and returns a not necessarily user-readable
  # string such as "NSAppearanceNameAqua" there and an empty string under all the other platforms.
  # @return [String]
  def get_appearance_name; end
  alias :appearance_name :get_appearance_name

  # Return true if the current system there is explicitly recognized as being a dark theme or if
  # the default window background is dark.
  #
  # This method should be used to check whether custom colours more appropriate for the default (light)
  # or dark appearance should be used.
  # return [true,false]
  def is_appearance_dark; end
  alias :appearance_dark? :is_appearance_dark

  # Return true if the default window background is significantly darker than foreground.
  #
  # This is used by #is_appearance_dark if there is no platform-specific way to determine whether a dark
  # mode is being used and is generally not very useful to call directly.
  # return [true,false]
  def is_appearance_using_dark_background; end
  alias :appearance_using_dark_background? :is_appearance_using_dark_background

end
