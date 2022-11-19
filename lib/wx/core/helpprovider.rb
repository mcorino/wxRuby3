# Base class for providing context-sensitive help. The main definition
# is in SWIG/C++ 
class Wx::HelpProvider
  class << self
    # We need to protect the currently set HelpProvider from GC as it is a
    # SWIG Director; it can't be reaped and re-wrapped later. The
    # easiest way is to make the currently set one an instance variable
    # of this class
    alias :__wx_set :set
    define_method(:set) do | help_provider |
      __wx_set(help_provider)
      @__hp__ = help_provider
    end
  end
end
