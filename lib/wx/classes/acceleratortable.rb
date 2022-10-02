class Wx::AcceleratorTable
  # Allow new to be called as []
  class << self
    alias :[] :new
  end

  # Allow initialize to be called with a splat-like list of arguments,
  # and allow entries to be specified in terser form [mod, key, id]
  # rather than full AcceleratorEntry.new call.
  wx_init = self.instance_method(:initialize)
  define_method(:initialize) do | *args |
    # Test for old-style arg passing in a single array
    if args.length == 1 and args.first.kind_of?(Array) and
       args.first.all? { | e | e.kind_of?(Wx::AcceleratorEntry) }
      args = args[0]
    end
    # Convert to array of AccEntries, to pass in as single array
    args = args.map do | entry |
      case entry 
      when Wx::AcceleratorEntry then entry
      when Array then Wx::AcceleratorEntry.new(*entry)
      else Kernel.raise ArgumentError,
                        "#{entry.inspect} is not a valid AcceleratorTable entry"
      end
    end
    wx_init.bind(self).call(args)
  end
end
