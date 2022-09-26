# Superclass of a variety of controls that display lists of items (eg
# Choice, ListBox, CheckListBox)
class Wx::ControlWithItems
  # Make these ruby enumerables so find, find_all, map etc are available 
  include Enumerable
  # Passes each valid item index into the passed block
  def each
    0.upto(get_count - 1) { | i | yield i }
  end
end
