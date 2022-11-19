# Pure-ruby implementation of the corresponding Wx class. Simply shows
# the Window's help text in a tooltip.
class Wx::SimpleHelpProvider < Wx::HelpProvider
  def initialize
    super
    # Store for mapping windows -> help strings
    @help_wins = {} 
    # Store for mapping ids -> help strings
    @help_ids  = {}
  end

  # This is what is called by Wx::Window#set_help_text
  def add_help(identifier, text)
    if identifier.kind_of? Wx::Window
      @help_wins[identifier.object_id] = text
    else
      @help_ids[identifier] = text
    end
  end

  # Retrieve help text for the given window +win+
  def get_help(win)
    @help_wins[win.object_id] || @help_ids[win.wx_id] || ""
  end

  # Remove the help text for +win+
  def remove_help(win)
    @help_wins.delete(win.object_id)
  end

  # Show help for +win+
  def show_help(win)
    help_text = get_help(win)
    return false if help_text.empty?
    tip = Wx::TipWindow.new(win, help_text, 100)
    true
  end
end
