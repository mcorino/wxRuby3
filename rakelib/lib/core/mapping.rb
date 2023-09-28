# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 typemap mapping classes
###

require 'set'

require_relative './parameter'

module WXRuby3

  module Typemap

    RubyArg = Struct.new(:type, :index) do
      def to_s
        "RubyArg{type=#{type}; index=#{index}}"
      end
      def inspect
        to_s
      end
    end

    STD_INT_TYPES = [
      'char', 'unsigned char', 'wchar_t',
      'short', 'unsigned short',
      'int', 'unsigned int',
      'long', 'unsigned long',
      'long int', 'unsigned long int',
      'long long', 'unsigned long long',
      'ssize_t', 'size_t'
      ]
    STD_FLOAT_TYPES = %w[float double]
    STD_STR_TYPES = ['char*', 'unsigned char*', 'wchar_t*']
    STD_BOOL_TYPES = %w[bool]

    class << self
      def map_std_type(std_type)
        if STD_INT_TYPES.include?(std_type)
          'Integer'
        elsif STD_FLOAT_TYPES.include?(std_type)
          'Float'
        elsif STD_STR_TYPES.include?(std_type)
          'String'
        elsif STD_BOOL_TYPES.include?(std_type)
          'true,false'
        else
          nil
        end
      end

      def std_type_maps
        @std_type_maps ||= {}
      end

      def register_std_typedef(wx_type, std_type)
        std_type_maps[wx_type] = map_std_type(std_type) || wx_type
      end
    end

    def self.rb_void_type(ctype)
      "VOID_#{ctype.tr(' ', '_').upcase}"
    end

    def self.strip_type_decl(ctype)
      ctype = ctype.gsub(/const\s+/, '')
      ctype.gsub!(/\s+(\*|&)/, '\1')
      ctype.strip!
      ctype.tr!('*&', '')
      ctype
    end

    def self.wx_type_to_rb(typestr)
      c_type = strip_type_decl(typestr)
      (std_type_maps[c_type] || c_type).sub(/\Awx/, 'Wx::')
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

        def to_s
          "#{kind} #{@map}"
        end

        def _get_mapped_type(type)
          mapped_type = case type
                        when RubyArg
                          type
                        when ::Array
                          RubyArg[*type]
                        when ::Hash
                          RubyArg[type[:type], type[:index]]
                        else
                          RubyArg[type.to_s]
                        end
        end
        private :_get_mapped_type

        def _map_args(argdef, argmap)
          if ::Hash === argdef && !argdef.has_key?(:type)
            argdef.each_pair do |argmasks, type|
              pattern = @map.patterns.detect { |ps| ps == argmasks }
              raise "Unknown parameter set [#{argmasks}] for [#{to_s}]" unless pattern
              argmap[pattern] = _get_mapped_type(type)
            end
          else
            mapped_type = _get_mapped_type(argdef)
            @map.patterns.each { |pattern| argmap[pattern] = mapped_type }
          end
          argmap
        end
        protected :_map_args
      end

      class In < Base
        def initialize(map, from: nil, ignore: nil, temp: nil, code: nil, &block)
          super(map, temp: temp, code: code)
          raise "Cannot combine 'from' and 'ignore' in #{to_s}" if from && ignore
          @from = {}
          @ignore = ignore
          if from
            map_from(from)
          elsif !ignore
            map.types.each_pair { |pset, type| @from[pset] = _get_mapped_type(type) }
            @ignore = @from.empty?
          end
          block.call(self) if block
        end

        attr_reader :from

        def map_from(argdef)
          @ignore = _map_args(argdef, @from).empty?
        end

        def ignore?
          @ignore
        end

        def modifiers
          ignore? ? ",numinputs=0" : nil
        end
      end

      class Default < Base
        def initialize(map, temp: nil, code: nil, &block)
          super(map, temp: temp, code: code)
          block.call(self) if block
        end
      end

      class Typecheck < Base
        def initialize(map, precedence: nil, temp: nil, code: nil, &block)
          super(map, temp: temp, code: code)
          @precedence = precedence
          block.call(self) if block
        end

        def modifiers
          if @precedence
            %Q[,precedence=#{Integer === @precedence ? @precedence : "SWIG_TYPECHECK_#{@precedence.to_s.upcase}"}]
          else
            nil
          end
        end
      end

      class Check < Base
        def initialize(map, temp: nil, code: nil, &block)
          super(map, temp: temp, code: code)
          block.call(self) if block
        end
      end

      class Out < Base
        def initialize(map, ignore: nil, to: nil, temp: nil, code: nil, &block)
          super(map, temp: temp, code: code)
          @ignored = ignore ? [ignore].flatten : []
          @ignore = !!ignore
          @to = {}
          if to
            map_to(to)
          elsif !(@ignore || map.types.empty?)
            map.types.each_pair { |pset, type| @to[pset] = _get_mapped_type(type) }
          end
          block.call(self) if block
        end

        attr_reader :ignored, :to

        def map_to(typedef)
          if ::Hash === typedef
            typedef.each_pair do |argmasks, type|
              pattern = @map.patterns.detect { |ps| ps == argmasks }
              raise "Unknown parameter set [#{argmasks}] for [#{@map}]" unless pattern
              @to[pattern] = _get_mapped_type(type)
            end
          else
            @map.patterns.inject(@to) do |map, pattern|
              map[pattern] = _get_mapped_type(typedef)
              map
            end
          end
          raise "Cannot combine 'ignore' and 'to' mapping in #{to_s}" if @ignore && !@to.empty?
        end

        def ignore?
          @ignore
        end

        def ignored_out_to_swig(typename)
          <<~__SWIG
            typedef #{typename} #{Typemap.rb_void_type(typename)};
            %{
              typedef #{typename} #{Typemap.rb_void_type(typename)};
            %}
            %typemap(out) #{Typemap.rb_void_type(typename)} \"wxUnusedVar(result);\";
            %typemap(directorout) #{Typemap.rb_void_type(typename)} \"\";
            __SWIG
        end
        private :ignored_out_to_swig

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
        def initialize(map, as: nil, by_ref: false, temp: nil, code: nil, &block)
          super(map, temp: nil, code: code)
          @as = {}
          if as
            map_as(as)
          elsif !map.types.empty?
            map.types.each_pair { |pset, type| @as[pset] = _get_mapped_type(type) }
          end
          @by_ref = by_ref
          block.call(self) if block
        end

        attr_reader :as, :by_ref

        def map_as(argdef)
          _map_args(argdef, @as)
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

      class Configurator
        def initialize(map)
          @map = map
        end
        def add_header_code(*code)
          @map.add_header_code(*code)
        end
        alias :add_header :add_header_code

        def map_in(**kwargs, &block)
          @map.map_in(**kwargs, &block)
        end

        def map_default(**kwargs, &block)
          @map.map_default(**kwargs, &block)
        end

        def map_typecheck(**kwargs, &block)
          @map.map_typecheck(**kwargs, &block)
        end

        def map_check(**kwargs, &block)
          @map.map_check(**kwargs, &block)
        end

        def map_out(**kwargs, &block)
          @map.map_out(**kwargs, &block)
        end

        def map_freearg(**kwargs, &block)
          @map.map_freearg(**kwargs, &block)
        end

        def map_argout(**kwargs, &block)
          @map.map_argout(**kwargs, &block)
        end

        def map_directorin(**kwargs, &block)
          @map.map_directorin(**kwargs, &block)
        end

        def map_directorout(**kwargs, &block)
          @map.map_directorout(**kwargs, &block)
        end

        def map_directorargout(**kwargs, &block)
          @map.map_directorargout(**kwargs, &block)
        end

        def map_varout(**kwargs, &block)
          @map.map_varout(**kwargs, &block)
        end
      end

      def initialize(*mappings, as: nil, swig: true, &block)
        @types = {}
        @patterns = mappings.collect do |mapping|
          if ::Hash === mapping
            mapping.collect do |pattern, type|
              pset = ParameterSet === pattern ? pattern : ParameterSet.new(pattern)
              @types[pset] = type
              pset
            end
          else
            ParameterSet === mapping ? mapping : ParameterSet.new(mapping)
          end
        end.flatten
        @patterns.each { |pset| @types[pset] = as unless @types.has_key?(pset) } if as
        @swig = swig
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
        @varout = nil
        @header_code = []
        Configurator.new(self).instance_eval &block if block
      end

      attr_reader :patterns, :types

      def swig?
        @swig
      end

      def add_header_code(*code)
        @header_code.concat(code.flatten)
      end

      def map_in(from: nil, ignore: nil, temp: nil, code: nil, &block)
        @in = In.new(self, from: from, ignore: ignore, temp: temp, code: code, &block)
      end

      def map_default(temp: nil, code: nil, &block)
        @default = Default.new(self, temp: temp, code: code, &block)
      end

      def map_typecheck(precedence: nil, temp: nil, code: nil, &block)
        @typecheck = Typecheck.new(self, precedence: precedence, temp: temp, code: code, &block)
      end

      def map_check(temp: nil, code: nil, &block)
        @check = Check.new(self, temp: temp, code: code, &block)
      end

      def map_out(ignore: nil, to: nil, temp: nil, code: nil, &block)
        @out = Out.new(self, ignore: ignore, to: to, temp: temp, code: code, &block)
      end

      def map_freearg(temp: nil, code: nil, &block)
        @check = FreeArg.new(self, temp: temp, code: code, &block)
      end

      def map_argout(as: nil, by_ref: false, temp: nil, code: nil, &block)
        @argout = ArgOut.new(self, as: as, by_ref: by_ref, temp: temp, code: code, &block)
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
        @varout = VarOut.new(self, temp: temp, code: code, &block)
      end

      def resolve(_)
        self
      end

      def matches?(pattern)
        @patterns.any? { |p| p == pattern }
      end

      def mapped_arg_input(arg_pattern)
        if maps_input? && !ignores_input? && tm_pset = @patterns.detect { |p| p == arg_pattern }
          @in.from[tm_pset]
        else
          nil
        end
      end

      def mapped_arg_output(arg_pattern)
        if maps_input_as_output? && tm_pset = @patterns.detect { |p| p == arg_pattern }
          @argout.as[tm_pset]
        else
          nil
        end
      end

      def map_input(parameters, param_offset)
        # does this map handle input mapping?
        if (maps_input? || maps_input_as_output?) &&
            # and if so, do any of the pattern sets match the first parameter
            !(tm_psets = @patterns.select { |pset| pset.param_masks.first == parameters.first }).empty?
          # ok, find first for which the rest of the pattern (if any) matches as well?
          tm_pset = tm_psets.detect do |pset|
            pset.param_masks.size == 1 ||
              (parameters.size >= pset.param_masks.size &&
                (1...pset.param_masks.size).all? { |pi| pset.param_masks[pi] == parameters[pi] })
          end
          if tm_pset
            in_arg = nil
            # map the matched parameters
            if maps_input?
              unless ignores_input?
                mapped_arg = @in.from[tm_pset]
                paramnr = mapped_arg.index || 0
                in_arg = RubyArg.new(mapped_arg.type,
                                     param_offset+paramnr)
              end
            end
            out_arg = nil
            if maps_input_as_output?
              mapped_arg = @argout.as[tm_pset]
              paramnr = mapped_arg.index || 0
              out_arg = RubyArg.new(mapped_arg.type,
                                    param_offset+paramnr)
            end
            # shift mapped parameters
            parameters.shift(tm_pset.param_masks.size)
            # return mappings
            return [in_arg, out_arg]
          end
        end
        nil
      end

      def map_output(type)
        if maps_output?
          if ignores_output? && ignored_output.include?(type)
            return ''
          end
          if (tm_pset = @patterns.detect { |pset| pset == type })
            return @out.to.has_key?(tm_pset) ? @out.to[tm_pset].type : ''
          end
        end
        nil
      end

      def maps_input?
        !!@in
      end

      def maps_output?
        !!@out
      end

      def ignores_input?
        @in && @in.ignore?
      end

      def maps_input_as_output?
        @argout && !@argout.by_ref
      end

      def ignores_output?
        @out && @out.ignore?
      end

      def ignored_output
        @out ? @out.ignored : []
      end

      def to_swig
        if swig?
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
                  @directorargout,
                  @varout]
          maps << @directorout unless ignores_output?
          s.concat maps.collect { |mapping| mapping ? mapping.to_swig : nil }.compact
        else
          []
        end
      end

      def to_s
        "typemap #{@patterns.join(', ')}"
      end

      def inspect
        to_s
      end
    end # Map

    class AppliedMap
      def initialize(src_pattern, *mappings)
        @patterns = mappings.collect { |paramset| ParameterSet.new(paramset) }
        @src_pattern = src_pattern
        @applied_maps = nil
      end

      attr_reader :patterns

      def resolve(resolver)
        unless @applied_maps
          @applied_maps = resolver.call(@src_pattern).reverse + STANDARD.find_all(@src_pattern) # assume system (SWIG) defined map if not found
          STDERR.puts "*** apply #{@applied_maps} (from #{@src_pattern}) for #{@patterns}" if Director.trace?
        end
        self
      end

      def matches?(pattern)
        @patterns.any? { |p| p == pattern }
      end

      def mapped_arg_input(arg_pattern)
        if maps_input? && !ignores_input? && @patterns.any? { |p| p == arg_pattern }
          @applied_maps.detect { |tm| tm.maps_input? && !tm.ignores_input? }.mapped_arg_input(@src_pattern)
        else
          nil
        end
      end

      def mapped_arg_output(arg_pattern)
        if maps_input_as_output? && @patterns.any? { |p| p == arg_pattern }
          @applied_maps.detect { |tm| tm.maps_input_as_output? }.mapped_arg_output(@src_pattern)
        else
          nil
        end
      end

      def map_input(parameters, param_offset)
        # does this map handle input mapping?
        if (maps_input? || maps_input_as_output?) &&
          # and if so, do any of the pattern sets match the first parameter
          !(tm_psets = @patterns.select { |pset| pset.param_masks.first == parameters.first }).empty?
          # ok, do any match the rest of the pattern (if any) as well?
          tm_match = tm_psets.any? do |pset|
            pset.param_masks.size == 1 ||
              (parameters.size >= pset.param_masks.size &&
                (1...pset.param_masks.size).all? { |pi| pset.param_masks[pi] == parameters[pi] })
          end
          if tm_match
            # find the applied map mapping input (if any)
            tm_app = @applied_maps.detect { |tm| tm.maps_input? }
            in_arg = nil
            # map the matched parameters
            if tm_app
              unless tm_app.ignores_input?
                mapped_arg = tm_app.mapped_arg_input(@src_pattern)
                paramnr = mapped_arg.index || 0
                in_arg = RubyArg.new(mapped_arg.type,
                                     param_offset+paramnr)
              end
            end
            # find the applied map mapping arg output (if any)
            tm_app = @applied_maps.detect { |tm| tm.maps_input_as_output? }
            out_arg = nil
            if tm_app
              mapped_arg = tm_app.mapped_arg_output(@src_pattern)
              paramnr = mapped_arg.index || 0
              out_arg = RubyArg.new(mapped_arg.type,
                                    param_offset+paramnr)
            end
            # shift mapped parameters
            parameters.shift(@src_pattern.param_masks.size)
            # return mappings
            return [in_arg, out_arg]
          end
        end
        nil
      end

      def map_output(type)
        if maps_output?
          if ignores_output? && ignored_output.include?(type)
            return ''
          end
          return @applied_maps.detect { |tm| tm.maps_output? }.map_output(type)
        end
        nil
      end

      def maps_input?
        @applied_maps ? @applied_maps.any? { |map| map.maps_input? } : false
      end

      def maps_output?
        @applied_maps ? @applied_maps.any? { |map| map.maps_output? } : false
      end

      def ignores_input?
        @applied_maps ? @applied_maps.any? { |map| map.ignores_input? } : false
      end

      def maps_input_as_output?
        @applied_maps ? @applied_maps.any? { |map| map.maps_input_as_output? } : false
      end

      def ignores_output?
        @applied_maps ? @applied_maps.any? { |map| map.ignores_output? } : false
      end

      def ignored_output
        ignores_output? ? @applied_maps.detect { |map| map.ignores_output? }.ignored_output : []
      end

      def to_swig
        "%apply #{@src_pattern} { #{@patterns.join(', ')} };"
      end

      def to_s
        "applied typemap #{@patterns.join(', ')} (applies #{@applied_maps})"
      end

      def inspect
        to_s
      end
    end

    class SystemMap

      def initialize(*mappings, maps_in: false, maps_argout: false, maps_out: false, mapped_type: nil)
        @patterns = mappings.collect { |paramset| ParameterSet === paramset ? paramset : ParameterSet.new(paramset) }
        @maps_in = maps_in || @patterns.any? { |p| p.param_masks.any? { |m| m.name == 'INPUT' } }
        @maps_argout = maps_argout || @patterns.any? { |p| p.param_masks.any? { |m| m.name == 'OUTPUT' } }
        @maps_out = maps_out
        @mapped_type = mapped_type
      end

      attr_reader :patterns

      def resolve(_)
        self
      end

      def matches?(pattern)
        @patterns.any? { |p| p == pattern }
      end

      def mapped_arg_input(arg_pattern)
        if maps_input? && !ignores_input? && @patterns.any? { |p| p == arg_pattern }
          RubyArg.new(@mapped_type)
        else
          nil
        end
      end

      def mapped_arg_output(arg_pattern)
        if maps_input_as_output? && @patterns.any? { |p| p == arg_pattern }
          RubyArg.new(@mapped_type)
        else
          nil
        end
      end

      def map_input(parameters, param_offset)
        # does this map handle input mapping?
        if (maps_input? || maps_input_as_output?) &&
          # and if so, do any of the pattern sets match the first parameter
          !(tm_psets = @patterns.select { |pset| pset.param_masks.first == parameters.first }).empty?
          # ok, find first for which the rest of the pattern (if any) matches as well?
          tm_pset = tm_psets.detect do |pset|
            pset.param_masks.size == 1 ||
              (parameters.size >= pset.param_masks.size &&
                (1...pset.param_masks.size).all? { |pi| pset.param_masks[pi] == parameters[pi] })
          end
          if tm_pset
            in_arg = nil
            # map the matched parameters
            if maps_input?
              in_arg = RubyArg.new(@mapped_type,
                                   param_offset)
            end
            out_arg = nil
            if maps_input_as_output?
              out_arg = RubyArg.new(@mapped_type,
                                    param_offset)
            end
            # shift mapped parameters
            parameters.shift(tm_pset.param_masks.size)
            # return mappings
            return [in_arg, out_arg]
          end
        end
        nil
      end

      def map_output(type)
        if maps_output? && matches?(type)
          return @mapped_type
        end
        nil
      end

      def maps_input?
        @maps_in
      end

      def ignores_input?
        @maps_argout && !@maps_in
      end

      def maps_input_as_output?
        @maps_argout
      end

      def maps_output?
        @maps_out
      end

      def ignores_output?
        false
      end

      def ignored_output
        []
      end

      def to_swig
        nil
      end

      def to_s
        "system typemap #{@patterns.join(', ')}"
      end

      def inspect
        to_s
      end
    end

    # This typemap disables (clears) any previous type mapping for the given argument pattern.
    # For SWIG it generates the '%clear' declaration.
    # For doc generation it simply shortcuts input and output mappings on any argument or return
    # type matching the pattern and 'maps' to the actual argument/return type.
    # No argument output or argument/return ignoring.
    class DisabledMap
      def initialize(pattern)
        @pattern = ParameterSet.new(pattern)
      end

      def patterns
        [@pattern]
      end

      def resolve(_)
        self
      end

      def matches?(pattern)
        @pattern == pattern
      end

      def mapped_arg_input(arg_pattern)
        nil
      end

      def mapped_arg_output(arg_pattern)
        nil
      end

      def map_input(parameters, param_offset)
        # does the pattern match the first parameter?
        if @pattern.param_masks.first == parameters.first
          # just 'map' the parameter to itself
          param = parameters.shift # loose the 'mapped' parameter
          return [RubyArg[nil, param_offset], nil]
        end
        nil
      end

      def map_output(type)
        # if matches?(type)
        #   return Typemap.wx_type_to_rb(type)
        # end
        nil
      end

      def maps_input?
        true
      end

      def maps_output?
        true
      end

      def ignores_input?
        false
      end

      def maps_input_as_output?
        false
      end

      def ignores_output?
        false
      end

      def ignored_output
        []
      end

      def to_swig
        "%clear #{@pattern};"
      end

      def to_s
        "cleared typemap #{@pattern}"
      end

      def inspect
        to_s
      end
    end

    class Collection
      module EnumHelpers
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

        def find_all(*patterns)
          if patterns.size == 1
            # in case of a single pattern find the first map matching the pattern
            pattern = ParameterSet === patterns.first ? patterns.first : ParameterSet.new(patterns.first)
            list.select { |map| map.matches?(pattern) }
          else
            # in case of multiple patterns the list must exactly identical as the pattern list of a map
            patterns = patterns.collect { |p| ParameterSet === p ? p : ParameterSet.new(p) }
            list.select { |map| map.patterns == patterns }
          end
        end

        def select(&block)
          list.select(&block)
        end

        def collect(&block)
          list.inject(Collection.new) { |c, tm| c.list << block.call(tm); c }
        end
      end

      def initialize
        @list = []
      end

      attr_reader :list

      include EnumHelpers

      def add(typemap)
        @list << typemap
        self
      end
      alias :<< :add

      def to_swig
        @list.collect { |map| map.to_swig }.flatten.compact
      end

      def to_s
        "typemap collection"
      end

      class Chain
        def initialize(*collections)
          @collections = collections.collect do |coll|
            raise ArgumentError,
                  "Do not know how to chain #{coll}. Expected Typemap::Collection" unless Collection === coll || Chain === coll
            coll
          end
        end

        def list
          ::Enumerator::Chain.new(*@collections.collect { |c| c.list })
        end

        include EnumHelpers

        def resolve
          resolver = ->(pattern) { self.find_all(pattern) }
          list.each { |tm| tm.resolve(resolver) }
          self
        end

        def map_input(parameters)
          param_offset = 0
          args = []
          ret = []
          reverse_list = list.reverse_each
          while !parameters.empty?
            result = nil
            param_count = parameters.size
            reverse_list.detect { |map| result = map.map_input(parameters, param_offset) }
            arg_in = arg_out = nil
            if result
              arg_in, arg_out = result
            else
              arg_in = RubyArg.new(nil, param_offset)
              parameters.shift # loose the mapped param
            end
            # store mapped param
            args << arg_in if arg_in
            ret << arg_out if arg_out
            # calculate new param offset
            param_offset += (param_count - parameters.size)
          end
          [args, ret]
        end

        def map_output(type)
          result = nil
          list.reverse_each.detect { |map| result = map.map_output(type) }
          result
        end

        def to_swig
          @collections.collect { |coll| coll.to_swig }.join("\n")
        end

        def to_s
          "typemap collection chain"
        end
      end
    end

    # set up standard SWIG defined type maps
    STANDARD = {
      STD_INT_TYPES => 'Integer',
      STD_STR_TYPES => 'String',
      STD_FLOAT_TYPES => 'Float',
      STD_BOOL_TYPES => 'true,false'
    }.inject(Typemap::Collection.new) do |list, (ctypes, rbtype)|
      unless rbtype == 'String'
        list << SystemMap.new(*ctypes.collect { |t| ["#{t} * OUTPUT", "#{t} & OUTPUT"]}.flatten,
                              mapped_type: rbtype)
        list << SystemMap.new(*ctypes.collect { |t| ["#{t} * INPUT", "#{t} & INPUT"]}.flatten,
                              mapped_type: rbtype)
      end
      list << SystemMap.new(*ctypes, maps_in: true, maps_out: true, mapped_type: rbtype)
    end << SystemMap.new('void', maps_out: true, mapped_type: 'void')

    module MappingMethods

      # creates a type mapping set
      def map(*mappings, &block)
        as = nil
        swig = true
        if ::Hash === mappings.last && (mappings.last.has_key?(:as) || mappings.last.has_key?(:swig))
          as = mappings.last.delete(:as)
          swig = !!mappings.last.delete(:swig) if mappings.last.has_key?(:swig)
        end
        type_maps << Map.new(*mappings, as: as, swig: swig, &block)
      end

      # creates type mapping applications sets for different parameter sets
      def map_apply(application)
        application.each_pair do |src_mapping, tgt_mappings|
          src_pattern = ParameterSet.new(src_mapping)
          type_maps << AppliedMap.new(src_pattern, *[tgt_mappings].flatten)
        end
      end

      def map_disable(pattern)
        type_maps << DisabledMap.new(pattern)
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
            # do we have an #on_include handler?
            self.on_include(map_user_mod) if self.respond_to?(:on_include)
            # first time we included a type map module?
            unless map_user_mod.singleton_class.include?(Typemap::MappingMethods)
              # add map creation and collection support methods
              map_user_mod.singleton_class.class_eval do
                # provide the map creation methods
                include Typemap::MappingMethods
                # define type_maps collection initializer
                def init_type_maps
                  @type_maps = Collection.new
                  # create the type maps from included type map modules (by us or our ancestors)
                  self.included_modules.reverse.select { |mod| mod.include?(Typemap::Module) }.each { |mod| mod.add_maps(self) }
                  @type_maps
                end
                private :init_type_maps
                # type maps accessor
                def type_maps
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
