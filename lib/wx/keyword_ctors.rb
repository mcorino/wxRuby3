# WxRuby Extensions - Keyword Constructors for wxRuby3
# Copyright (c) M.J.N. Corino, The Netherlands
# Adapted from wxRuby2.

module Wx
  # = WxSugar - Keyword Constructors Classes
  #
  # This extension defines the keyword parameters for +new+ methods for
  # widgets, windows and frames. It's for use with *Keyword Constructors*
  # and is no use on its own - except if you are looking for a bug or want
  # to add a  missing class.
  #
  # For each class, the parameters *must* be declared in the order that
  # they are supplied to wxRuby. A parameter is specified by a symbol
  # name, and, optionally, a default argument which will be of whatever type
  # the wxRuby core library accepts.
  # To support complex (context dependent) defaults and/or autoconversion
  # of arguments for backwards the specified default can also be a lambda
  # or  a proc accepting a single argument. This argument will be the
  # value of the specified parameter (or nil) and the lambda or proc
  # should return the constructed or converted argument value to be used.
  #
  # Some common parameters to constructors such as size, position, title,
  # id and so forth always have a standard default argumnet, which is
  # defined in keyword_ctors. In these cases, it is not necessary to
  # supply the default argument in the definition.
  @defined_kw_classes = {}

  # accepts a string unadorned name of a WxWidgets class, and block, which
  # defines the constructor parameters and style flags for that class.
  # If the named class exists in the available WxRuby, the block is run and
  # the class may use keyword constructors. If the class is not available, the
  # block is ignored.
  def self.define_keyword_ctors(klass, &block)
    klass_name = ::String === klass ? klass : klass.name
    # check this class hasn't already been defined
    if @defined_kw_classes[klass_name]
      raise ArgumentError, "Keyword ctor for #{klass_name} already defined"
    else
      @defined_kw_classes[klass_name] = true
    end

    begin
      klass =  Wx::const_get(klass_name)
    rescue NameError
      STDERR.puts "WARNING: cannot define keyword ctor for #{klass_name}" if Wx::DEBUG
      return nil
    end if ::String === klass
    # If the klass inherited from a class which already has keyword ctor defined
    # it will already have a param_spec class attribute defined.
    # We need to clear it here because we're going to define a new param_spec for
    # this specific derivative.
    unless klass.respond_to?(:param_spec)
      klass.include Wx::KeywordConstructor::ParamSpec
    end
    klass.param_spec = []
    klass.include Wx::KeywordConstructor
    klass.instance_eval(&block)
  end

  module KeywordConstructor

    # This module defines an inheritable class attribute like the ones defined
    # by the Rails #class_attribute method.
    module ParamSpec
      def self.included(mod)
        mod.class_eval do
          def self.param_spec
            nil
          end

          def self.param_spec?
            !!param_spec
          end

          def self.param_spec=(val)
            singleton_class.class_eval do
              if method_defined?(:param_spec) || private_method_defined?(:param_spec)
                begin
                  remove_method(:param_spec);
                rescue NameError;
                end
              end
              define_method(:param_spec) { val }
            end

            if singleton_class?
              class_eval do
                if method_defined?(:param_spec) || private_method_defined?(:param_spec)
                  begin
                    remove_method(:param_spec);
                  rescue NameError;
                  end
                end

                def param_spec
                  defined?(@param_spec) ? @param_spec : singleton_class.param_spec
                end
              end
            end
            val
          end

          if method_defined?(:param_spec) || private_method_defined?(:param_spec)
            begin
              remove_method(:param_spec);
            rescue NameError;
            end
          end

          def param_spec
            defined?(@param_spec) ? @param_spec : self.class.param_spec
          end

          def param_spec?
            !!param_spec
          end
        end
      end
    end

    # This module adds the class methods needed to define and use keyword ctors.
    module ClassMethods

      # Common Wx constructor argument keywords, with their default values.
      STANDARD_DEFAULTS = {
        :id        => Wx::StandardID::ID_ANY,
        :size      => Wx::DEFAULT_SIZE,
        :pos       => Wx::DEFAULT_POSITION,
        :style     => 0,
        :title     => '',
        :validator => Wx::DEFAULT_VALIDATOR,
        :choices   => [] # for Choice, ComboBox etc
      }

      # Adds a list of named parameters *params* to the parameter
      # specification for this Wx class's constructor. Each parameter
      # should be specified as a either a common known symbol, such as
      # +:size+ or +:pos:+ or +:style:+ (corresponding to the common
      # constructor arguments in WxWidgets API), or a single-key with the
      # key the name of the argument, and the value a default value.
      # 
      # Parameters should be specified in the order they occur in the Wx
      # API constructor
      def wx_ctor_params(*params)
        self.param_spec += params.map do | param |
          param.kind_of?(Hash) ? 
            Parameter[ param.keys.first, param.values.first ] : 
            Parameter[ param, STANDARD_DEFAULTS[param] ]
        end
      end

      def args_as_list(*mixed_args)
        Wx::args_as_list(param_spec, *mixed_args)
      end

      def args_as_hash(*mixed_args)
        kwa = mixed_args.last.kind_of?(Hash) ? mixed_args.pop : {}
        param_spec.zip(mixed_args) do | param, arg |
          kwa[param.name] = arg if arg
        end
        kwa 
      end
      
      def describe_constructor(txt = '')
        param_spec.inject(txt) do | desc, param |
          if Proc === param.default_or_proc
            desc << ":#{param.name} => (#{param.default_or_proc.call(nil).class.name})\n"
          else
            desc << ":#{param.name} => (#{param.default_or_proc.class.name})\n"
          end
        end
      end
    end

    def self.included(klass)
      klass.extend ClassMethods

      # This defines the overridden ctor that accepts and use the keyword param specs.
      klass.module_eval do

        alias :pre_wx_kwctor_init :initialize

        # The new definition of initialize; accepts a parent arg
        # mixed_args, which may zero or more position args, optionally
        # terminated with hash keyword args, and an optional block
        def initialize(parent = :default_ctor, *mixed_args, &block)
          # allow zero-args ctor for use with XRC
          if parent == :default_ctor
            pre_wx_kwctor_init
            return
          end

          begin
            real_args = [ parent ] + self.class.args_as_list(*mixed_args)
            pre_wx_kwctor_init(*real_args)
          rescue => err
            msg = "Error initializing #{self.inspect}\n"+
                  " : #{err.message} \n" +
                  "Provided are #{real_args} \n" +
                  "Correct parameters for #{self.class.name}.new are:\n" +
                   self.class.describe_constructor()

            new_err = err.class.new(msg)
            new_err.set_backtrace(caller)
            Kernel.raise new_err
          end

          # If a block was given, pass the newly created Window instance
          # into it; use block
          if block
            if block.arity == -1 or block.arity == 0
              self.instance_eval(&block)
            elsif block.arity == 1
              block.call(self)
            else
              Kernel.raise ArgumentError,
                           "Block to initialize should accept a single argument or none"
            end
          end
        end
      end
    end

  end
end
