###
# wxRuby3 typemap Parameter class
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  module Typemap

    # represents a basic parameter definition
    class ParameterBase
      PTR_RE = /\A(\*|&)([_a-zA-Z]\w*)\Z/
      CONST_RE = /(\Aconst|\Wconst)\W/
      def initialize(param)
        @array = false
        if ::Array === param
          @ctype, @name, arr = param
          @array = (arr == '[]' || arr == true)
          if ::String === @name && @name.end_with?('[]')
            @array = true
            @name = @name[0..-3]
          end
        else
          # split the param spec on spaces
          list = param.to_s.split(' ')
          # name (if provided) is expected at end
          @name = list.pop
          if @name == '[]' || @name.end_with?('[]') # name or array indicator (or both)?
            @array = true # array type specificied
            # remove indicator from name or pop actual name id from split list
            @name = (@name == '[]' ? list.pop : @name[0..-3])
          end
          @ctype = list.join(' ') # put type string back together
          # strip all 'const' modifiers
          tmp = @ctype.gsub(CONST_RE) { |s| "#{s.start_with?('c') ? '' : s[0]}#{s[-1]}" }
          # check if there is still an identifier left
          if /\w+/ =~ tmp
            # does the name still contain a pointer/reference indicator?
            PTR_RE.match(@name) do |md|
              @ctype << md[1] # attach to type
              @name = md[2] # remove from name
            end
          else
            # @name is actually the type identifier and this parameter spec is nameless
            @ctype << (@ctype.empty? ? '' : ' ') << @name # concatenate type
            @name = nil
          end
        end
      end

      attr_reader :ctype

      def array?
        @array
      end

      def name
        @name.to_s
      end

      def to_s
        "#{ctype}#{name.empty? ? '' : ' '}#{name}#{array? ? '[]' : ''}"
      end
    end # ParameterBase

    # encapsulates a type mapping argument mask
    class ParameterMask < ParameterBase
      def initialize(mask_def)
        super
        @type_mask = ctype.tr(' ', '') # remove all spaces
      end

      attr_reader :type_mask

      def ==(param)
        case param
        when ParameterMask
          type_mask == param.type_mask && name == param.name && array? == param.array?
        when ArgumentDecl
          param == self
        when Extractor::ParamDef
          (name.empty? || name == param.name) &&
            type_mask == param.type.sub(/const\s*/, '').tr(' ', '') &&
            array? == param.array
        else
          ArgumentDecl.new(param.to_s) == self
        end
      end
    end # ParameterMask

    class ParameterSet
      def initialize(paramlist)
        @param_masks = if ::Array === paramlist
                         paramlist.collect { |param| ParameterMask.new(param) }
                       else
                         paramlist.split(',').collect { |param| ParameterMask.new(param) }
                       end
      end

      attr_reader :param_masks

      def ==(params)
        case params
        when ParameterSet
          @param_masks == params.param_masks
        when Extractor::FunctionDef
          match(params)
        else
          @param_masks == ParameterSet.new(params.to_s).param_masks
        end
      end

      private def match(funcdef)
        STDERR.puts "*** matching #{self} to #{funcdef.signature}"
        # see if the first parameter mask matches anywhere in the function's argument list
        if fpix = (0...funcdef.parameters.size).to_a.detect { |pix| @param_masks.first == funcdef.parameters[pix] }
          STDERR.puts "*** match found at argument #{fpix}"
          # if this is the only param mask we're done
          return true if @param_masks.size == 1
          # are there enough arguments to match all masks from the position of the argument we matched first?
          if (parameters.size - fpix) >= @param_masks.size
            # do the remainder of the parameter masks (if any) all match as well?
            fpix += 1 # start matching at the next function arg
            @param_masks[1,@param_masks.size-1].each_with_index do |pm, pix|
              return false unless pm == funcdef.parameters[fpix+pix]
            end
            return true # fully matched
          end
        end
        false
      end

      def to_s
        "(#{@param_masks.join(', ')})"
      end
    end

    # encapsulates a method argument declaration
    class ArgumentDecl < ParameterBase
      def initialize(argdecl)
        super
        # put together a list of possible argument type strings for matching
        @type_list = [ (ctype_str = ctype.dup).tr(' ', '') ]  # first is the unaltered type
        # next remove const modifiers from front to back (adding type strings for every reduction)
        while ctype_str.sub!(CONST_RE) { |s| "#{s.start_with?('c') ? '' : s[0]}#{s[-1]}" }
          @type_list << ctype_str.tr(' ', '')
        end
      end

      def ==(param_mask)
        unless ParameterMask === param_mask
          param_mask = ParameterMask.new(param_mask)
        end
        if array? == param_mask.array?
          if @type_list.any? {|typ| typ == param_mask.type_mask }
            return param_mask.name.nil? || param_mask.name == name
          end
        end
        false
      end
    end # ArgumentDecl

    class ArgumentList
      def initialize(arglist)
        @args = if ::Array === arglist
                  arglist.collect { |arg| ArgumentDecl.new(arg) }
                else
                  arglist.split(',').collect { |arg| ArgumentDecl.new(arg) }
                end
      end

      # match with parameter mask list and return index of first argument matching or nil
      def match(masks)
        masks = ParameterSet === masks ? masks.param_masks : [masks].flatten
        # see if this parameter mask list matches (a part of) this argument list
        if arg_ix = @args.find_index { |arg| arg == masks.first } # does the head mask match any argument?
          # anything left to match?
          return arg_ix unless masks.size>1
          # see if the following arguments match the rest of the masks
          if (@args.size - arg_ix) >= masks.size # matching numbers?
            return arg_ix if (1...masks.size).to_a.all? { |i| @args[arg_ix+i] == masks[i] }
          end
        end
        nil
      end

      def to_s
        @args.join(', ')
      end
    end

  end

end
