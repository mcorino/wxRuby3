###
# wxRuby3 typemap mapping classes
# Copyright (c) M.J.N. Corino, The Netherlands
###

require 'set'

require_relative './parameter'

module WXRuby3

  module Typemap

    RubyArg = Struct.new(:type, :name)

    def self.rb_void_type(ctype)
      "VOID_#{ctype.tr(' ', '_').upcase}"
    end

    class Map

      class Base
        def initialize(map, temp: nil, code: nil)
          @map = map
          @temporaries = [temp].flatten.compact
          @mapping_code = code ? [code.to_s] : []
        end

        def kind
          self.class.name.split('::').last.downcase.to_sym
        end

        def modifiers
          nil
        end
        protected :modifiers

        def add_temporaries(*temps)
          @temporaries.concat temps.flatten
        end

        def add_code(code)
          @mapping_code << code.to_s
        end

        def to_swig
          tmpstr = (@temporaries && !@temporaries.empty?) ? " (#{@temporaries.join(', ')})" : ''
          mods = modifiers
          argmasks = @map.patterns.collect { |p| "(#{p.param_masks.collect { |pm| pm.to_s }.join(', ')})#{tmpstr}" }.join(', ')
          if @mapping_code.inject(0) { |lc, s| lc += (1 + s.count("\n")); lc } > 1
            <<~__SWIG
              %typemap(#{kind}#{mods}) #{argmasks} {
                #{@mapping_code.collect { |s| s.split("\n") }.flatten.join("\n  ")}
              }
            __SWIG
          else
            %Q{%typemap(#{kind}#{mods}) #{argmasks} "#{@mapping_code.first}";}
          end
        end
      end

      class In < Base
        def initialize(map, ignore: false, temp: nil, code: nil, &block)
          super(map, temp: temp, code: code)
          @ignore = ignore
          block.call(self) if block
        end

        def modifiers
          @ignore ? ",numinputs=0" : nil
        end
      end

      class Default < Base
        def initialize(map, temp: nil, code: nil, &block)
          super(map, temp: temp, code: code)
          block.call(self) if block
        end
      end

      class Typecheck < Base
        def initialize(map, precedence: , temp: nil, code: nil, &block)
          super(map, temp: temp, code: code)
          @precedence = precedence
          block.call(self) if block
        end

        def modifiers
          @precedence ? ",precedence=SWIG_TYPECHECK_#{@precedence.to_s.upcase}" : nil
        end
      end

      class Check < Base
        def initialize(map, temp: nil, code: nil, &block)
          super(map, temp: temp, code: code)
          block.call(self) if block
        end
      end

      class Out < Base
        def initialize(map, ignore: nil, temp: nil, code: nil, &block)
          super(map, temp: temp, code: code)
          @ignored = ignore ? [ignore].flatten : []
          @ignore = !!ignore
          block.call(self) if block
        end

        attr_reader :ignored

        def ignore?
          @ignore
        end

        private def ignored_out_to_swig(typename)
          <<~__SWIG
            typedef #{typename} #{Typemap.rb_void_type(typename)};
            %{
              typedef #{typename} #{Typemap.rb_void_type(typename)};
            %}
            %typemap(out) #{Typemap.rb_void_type(typename)} \"wxUnusedVar(result);\";
            %typemap(directorout) #{Typemap.rb_void_type(typename)} \"wxUnusedVar(result);\";
            __SWIG
        end

        def to_swig
          @ignore ? @ignored.collect { |typename|  ignored_out_to_swig(typename) } : super
        end
      end

      class FreeArg < Base
        def initialize(map, temp: nil, code: nil, &block)
          super(map, temp: temp, code: code)
          block.call(self) if block
        end
      end

      class ArgOut < Base
        def initialize(map, temp: nil, code: nil, &block)
          super(map, temp: nil, code: code)
          block.call(self) if block
        end
      end

      class DirectorIn < Base
        def initialize(map, temp: nil, code: nil, &block)
          super(map, temp: temp, code: code)
          block.call(self) if block
        end
      end

      class DirectorOut < Base
        def initialize(map, temp: nil, code: nil, &block)
          super(map, temp: temp, code: code)
          block.call(self) if block
        end
      end

      class DirectorArgOut < Base
        def initialize(map, temp: nil, code: nil, &block)
          super(map, temp: temp, code: code)
          block.call(self) if block
        end
      end

      class VarOut < Base
        def initialize(map, temp: nil, code: nil, &block)
          super(map, temp: nil, code: code)
          block.call(self) if block
        end
      end

      def initialize(*mappings, &block)
        @patterns = mappings.collect { |paramset| ParameterSet === paramset ? paramset : ParameterSet.new(paramset) }
        @mapped_types = {}
        @in = nil
        @default = nil
        @typecheck = nil
        @check = nil
        @argout = nil
        @out = nil
        @freearg = nil
        @directorin = nil
        @directorargout = nil
        @directorout = nil
        @header_code = []
        self.instance_eval &block if block
      end

      attr_reader :patterns, :mapped_types

      def _get_mapped_type(type)
        mapped_type = case type
                      when RubyArg
                        type
                      when ::Array
                        RubyArg[*type]
                      when ::Hash
                        RubyArg[type[:type], type[:name]]
                      else
                        RubyArg[type.to_s]
                      end
      end
      private :_get_mapped_type

      def add_header_code(*code)
        @header_code.concat(code.flatten)
      end
      alias :add_header :add_header_code

      def map_type(types)
        if ::Hash === types && !types.has_key?(:type)
          types.each_pair do |argmasks, type|
            pattern = @patterns.detect { |ps| ps == argmasks }
            raise "Unknown parameter set [#{argmasks}] for [#{to_s}]" unless pattern
            mapped_type = _get_mapped_type(types)
            if ::Integer === mapped_type.name
              mapped_type.name = pattern.param_masks[mapped_type.name].name
            end
            @mapped_types[pattern] = _get_mapped_type(type)
          end
        else
          @patterns.inject(@mapped_types) do |map, pattern|
            mapped_type = _get_mapped_type(types)
            if ::Integer === mapped_type.name
              mapped_type.name = pattern.param_masks.fetch(mapped_type.name).name
            end
            map[pattern] = mapped_type
            map
          end
        end
      end

      def map_in(ignore: false, temp: nil, code: nil, &block)
        @in = In.new(self, ignore: ignore, temp: temp, code: code, &block)
      end

      def map_default(temp: nil, code: nil, &block)
        @default = Default.new(self, temp: temp, code: code, &block)
      end

      def map_typecheck(precedence: , temp: nil, code: nil, &block)
        @typecheck = Typecheck.new(self, precedence: precedence, temp: temp, code: code, &block)
      end

      def map_check(temp: nil, code: nil, &block)
        @check = Check.new(self, temp: temp, code: code, &block)
      end

      def map_out(ignore: nil, temp: nil, code: nil, &block)
        @out = Out.new(self, ignore: ignore, temp: temp, code: code, &block)
      end

      def map_freearg(temp: nil, code: nil, &block)
        @check = FreeArg.new(self, temp: temp, code: code, &block)
      end

      def map_argout(temp: nil, code: nil, &block)
        @argout = ArgOut.new(self, temp: temp, code: code, &block)
      end

      def map_directorin(temp: nil, code: nil, &block)
        @directorin = DirectorIn.new(self, temp: temp, code: code, &block)
      end

      def map_directorout(temp: nil, code: nil, &block)
        @directorout = DirectorOut.new(self, temp: temp, code: code, &block)
      end

      def map_directorargout(temp: nil, code: nil, &block)
        @directorargout = DirectorArgOut.new(self, temp: temp, code: code, &block)
      end

      def map_varout(temp: nil, code: nil, &block)
        @argout = VarOut.new(self, temp: temp, code: code, &block)
      end

      def matches?(pattern)
        @patterns.any? { |p| p == pattern }
      end

      def has_ignored_out?
        @out && @out.ignore?
      end

      def ignored
        @out ? @out.ignored : []
      end

      def to_swig
        s = []
        unless @header_code.empty?
          s << "%{\n"
          s.concat @header_code
          s << "\n%}"
        end
        maps = [@in,
                @default,
                @typecheck,
                @check,
                @argout,
                @out,
                @freearg,
                @directorin,
                @directorargout]
        maps << @directorout unless has_ignored_out?
        s.concat maps.collect { |mapping| mapping ? mapping.to_swig : nil }.compact
      end

      def to_s
        "typemap #{@patterns.join(', ')}"
      end

    end # Map

    class AppliedMap
      def initialize(applied_map, src_pattern, *mappings)
        @patterns = mappings.collect { |paramset| ParameterSet.new(paramset) }
        @src_pattern = src_pattern
        @applied_map = applied_map
      end

      attr_reader :patterns

      def matches?(pattern)
        @patterns.any? { |p| p == pattern }
      end

      def has_ignored_out?
        false
      end

      def to_swig
        "%apply #{@src_pattern} { #{@patterns.join(', ')} };"
      end

      def to_s
        "applied typemap #{@patterns.join(', ')} (applies #{@applied_map})"
      end
    end

    class SystemMap
      def initialize(*mappings)
        @patterns = mappings.collect { |paramset| ParameterSet === paramset ? paramset : ParameterSet.new(paramset) }
      end

      attr_reader :patterns

      def matches?(pattern)
        @patterns.any? { |p| p == pattern }
      end

      def has_ignored_out?
        false
      end

      def to_swig
        ''
      end

      def to_s
        "system typemap #{@patterns.join(', ')}"
      end
    end

    class Collection
      module Find
        def find(*patterns)
          if patterns.size == 1
            # in case of a single pattern find the first map matching the pattern
            pattern = ParameterSet === patterns.first ? patterns.first : ParameterSet.new(patterns.first)
            list.detect { |map| map.matches?(pattern) }
          else
            # in case of multiple patterns the list must exactly identical as the pattern list of a map
            patterns = patterns.collect { |p| ParameterSet === p ? p : ParameterSet.new(p) }
            list.detect { |map| map.patterns == patterns }
          end
        end

        def select(&block)
          list.select(&block)
        end
      end

      def initialize
        @list = []
      end

      attr_reader :list

      include Find

      def add(typemap)
        @list << typemap
      end
      alias :<< :add

      def to_swig
        @list.collect { |map| map.to_swig }.flatten
      end

      def to_s
        "typemap collection"
      end

      class Chain
        def initialize(*collections)
          @collections = collections.collect do |coll|
            raise ArgumentError,
                  "Do not know how to chain #{coll}. Expected Typemap::Collection" unless Collection === coll
            coll
          end
        end

        private def list
          ::Enumerator::Chain.new(*@collections.collect { |c| c.list })
        end

        include Find

        def to_swig
          @collections.collect { |coll| coll.to_swig }.join("\n")
        end

        def to_s
          "typemap collection chain"
        end
      end
    end

    module MappingMethods

      # creates a type mapping set
      def map(*mappings, &block)
        type_maps << Map.new(*mappings, &block)
      end

      # creates type mapping applications sets for different parameter sets
      def map_apply(application)
        application.each_pair do |src_mapping, tgt_mappings|
          src_pattern = ParameterSet.new(src_mapping)
          map = type_maps.find(src_pattern)
          map ||= SystemMap.new(src_pattern) # assume system (SWIG) defined map if not found
          type_maps << AppliedMap.new(map, src_pattern, *[tgt_mappings].flatten)
        end
      end

    end

    module Module

      def self.included(typemap_mod)
        typemap_mod.singleton_class.class_eval do
          def define(&block)
            @typemap_setup = block
          end

          def add_maps(typemap_user)
            typemap_user.module_eval &@typemap_setup
          end
        end

        # Define an include handler for the typemap module which sets up the module/class
        # using the typemap module (most likely a Director class).
        # The method implemented below makes sure type maps are ever only created when needed.
        typemap_mod.module_eval do
          def self.included(map_user_mod)
            # first time we included a type map module?
            unless map_user_mod.singleton_class.include?(Typemap::MappingMethods)
              # add map creation and collection support methods
              map_user_mod.singleton_class.class_eval do
                # provide the map creation methods
                include Typemap::MappingMethods
                # define type_maps collection initializer
                private def init_type_maps
                  @type_maps = Collection.new
                  # create the type maps from included type map modules (by us or our ancestors)
                  self.included_modules.reverse.select { |mod| mod.include?(Typemap::Module) }.each { |mod| mod.add_maps(self) }
                  @type_maps
                end
                # type maps accessor
                public def type_maps
                  @type_maps ||= init_type_maps
                end
              end
            end
          end
        end
      end

    end

  end # Typemap

end # WXRuby3
