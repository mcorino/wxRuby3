# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# 
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

# Various non-GUI helper functions for wxRuby3


module Wx

  # A named parameter in a Wx named-arg parameter list
  Parameter = Struct.new( :name, :default_or_proc )

  # Convert mixed positional / named args into a list to be passed to
  # an underlying API method. +param_spec+ is an Array of Parameter
  # structs containing the keyword name and default value for each
  # possible argument. +mixed_args+ is an array which may optionally end
  # with a set of named arguments
  if RUBY_VERSION < '3.0.0'
    def self.args_as_list(param_spec, *mixed_args)

      begin
        # get keyword arguments from mixed args if supplied, else empty
        kwa = mixed_args.last.kind_of?(Hash) ? mixed_args.pop : {}
        out_args = []
        param_spec.each_with_index do | param, i |
          # has supplied list arg or the keyword arg?
          arg = mixed_args[i]
          arg = kwa.delete(param.name) if arg.nil? && kwa.key?(param.name)
          if Proc === param.default_or_proc
            arg = param.default_or_proc.call(arg) # provides default or converts arg
          elsif arg.nil?
            arg = param.default_or_proc # simple default value
          end
          out_args << arg
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
  else
    def self.args_as_list(param_spec, *args, **kwargs)

      begin
        out_args = []
        param_spec.each_with_index do | param, i |
          # has supplied list arg or the keyword arg?
          arg = args[i]
          arg = kwargs.delete(param.name) if arg.nil? && kwargs.key?(param.name)
          if Proc === param.default_or_proc
            arg = param.default_or_proc.call(arg) # provides default or converts arg
          elsif arg.nil?
            arg = param.default_or_proc # simple default value
          end
          out_args << arg
        end
      rescue
        Kernel.raise ArgumentError,
                     "Bad arg composition of #{args.inspect}"
      end

      unless kwargs.empty?
        Kernel.raise ArgumentError,
                     "Unknown keyword argument(s) : #{kwargs.keys.inspect}"
      end

      out_args
    end
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

  def self.has_feature?(featsym)
    Wx::Setup.const_defined?(featsym) && !!Wx::Setup.const_get(featsym)
  end
end
