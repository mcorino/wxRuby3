# = WxSugar - Accessors
#
# The default WxRuby interface has lots and lots of methods like
#
#  * get_position()
#  * set_size(a_size)
#  * is_checked()
#  * can_undo()
#  * has_style(a_style)
# 
# and so on. Methods that retrieve set, or query attributes of an object
# are more normally in Ruby called simply by the attribute name, or, in
# other cases, with a predicate method:
#
#  * pos = my_widget.position
#  * my_widget.size = a_size
#  * my_widget.checked?
#  * my_widget.can_undo?
#  * my_widget.has_style?
#
# This extension creates an alias for every WxRuby instance method that
# begins with +get_+, +set_+, +is_+, +can_+ and +has_+. Note that if you are calling a
# 'setter' method on self, you must explicitly send the message to self:
# 
#  # set's self size to be 100px by 100px
#  self.size = Wx::Size.new(100, 100)
#  # only sets the value of a local variable 'size'
#  size = Wx::Size.new

module WxRubyStyleAccessors
  # Ruby-style method named are implemented by method-missing; if an
  # unknown method is called, see if it is a rubyish name for a real
  # method. In principle it would be possible to set up real aliases for
  # them at start-up, but in practice this is far too slow for all the
  # classes that need to be started up.
  def method_missing(sym, *args)
    case sym.to_s
    when /^(\w+)\=$/ 
      meth = "set_#{$1}"
    when /^((?:has|can)\w+)\?$/
      meth = $1
    when /^(\w+)\?$/
      meth = "is_#{$1}"
    else
      meth = "get_#{sym}"
    end
    if respond_to?(meth)
      send(meth, *args)
    else
      super
    end
  end
end

# Allow Wx-global functions to be accessed with nice syntax
module Wx
  extend WxRubyStyleAccessors
end

# Apply the syntax extensions to every class, both class methods and
# instance methods
all_classes = Wx::constants.collect { | c | Wx::const_get(c) }.grep(Class)
all_classes.each do | klass |
  klass.class_eval do
    include WxRubyStyleAccessors
    extend WxRubyStyleAccessors
  end
end
