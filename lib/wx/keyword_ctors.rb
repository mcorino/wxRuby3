# WxRuby Extensions - Keyword Constructors for wxRuby3
# Copyright (c) M.J.N. Corino, The Netherlands


module Wx
  module KeywordConstructor
    module ClassMethods

      # Common Wx constructor argument keywords, with their default values.
      STANDARD_DEFAULTS = {
        :id        => -1,
        :size      => Wx::DEFAULT_SIZE,
        :pos       => Wx::DEFAULT_POSITION,
        :style     => 0,
        :title     => '',
        :validator => Wx::DEFAULT_VALIDATOR,
        :choices   => [] # for Choice, ComboBox etc
      }

      attr_writer :param_spec
      def param_spec
        @param_spec ||= []
      end
      
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
      
      def describe_constructor
        param_spec.inject("") do | desc, param |
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
      klass.module_eval do

        alias :pre_wx_kwctor_init :initialize

        # The new definition of initialize; accepts a parent arg
        # mixed_args, which may zero or more position args, optionally
        # terminated with hash keyword args, and an optional block
        def initialize(parent = :default_ctor, *mixed_args, &block)
          # allow zero-args ctor for use with XRC
          if parent == :default_ctor
            pre_wx_kwctor_init()
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
                           "Block to initialize accepts zero or one arg"
            end
          end
        end
      end
      
      # Any class inheriting from a class including this module must have
      # its own copy of the param_spec
      def klass.inherited(sub_klass)
        sub_klass.instance_variable_set(:@param_spec, 
                                        instance_variable_get(:@param_spec).dup )
      end
    end
  end
end
