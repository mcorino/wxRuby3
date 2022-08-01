# Various non-GUI helper functions
module Wx
  # A named parameter in a Wx named-arg parameter list
  Parameter = Struct.new( :name, :default )

  # Convert mixed positional / named args into a list to be passed to
  # an underlying API method. +param_spec+ is an Array of Parameter
  # structs containing the keyword name and default value for each
  # possible argument. +mixed_args+ is an array which may optionally end
  # with a set of named arguments
  def self.args_as_list(param_spec, *mixed_args)

    begin
      # get keyword arguments from mixed args if supplied, else empty
      kwa = mixed_args.last.kind_of?(Hash) ? mixed_args.pop : {}
      out_args = []
      param_spec.each_with_index do | param, i |
        if arg = mixed_args[i] # use the supplied list arg 
          out_args << arg
        elsif kwa.key?(param.name) # use the keyword arg
          out_args << kwa.delete(param.name)
        else # use the default argument
          out_args << param.default
        end
      end
    rescue
      Kernel.raise ArgumentError, 
                 "Bad arg composition of #{mixed_args.inspect}"
    end

    unless kwa.empty?
      Kernel.raise ArgumentError, 
                 "Unknown keyword argument(s) : #{kwa.keys.inspect}"
    end

    out_args
  end

  # Given an integer constant +int_const+, returns an array Wx constant
  # names which have this value. If a string +prefix+ is supplied, find
  # only constants whose names begin with this prefix. For example,
  # passing "EVT" would return only constants with a name like
  # Wx::EVT_XXX
  # 
  # This is primarily useful for debugging, when an unknown constant is
  # returned, eg as an event type id.
  def self.find_const(sought, prefix = "")
    consts = constants.grep(/\A#{prefix}/)
    consts.find_all do | c | 
      c_val = const_get(c)
      c_val.instance_of?(Fixnum) and c_val == sought
    end
  end
end
