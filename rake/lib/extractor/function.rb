#--------------------------------------------------------------------
# @file    variable.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface extractor
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

module WXRuby3

  module Extractor

    # Information about a standalone function.
    class FunctionDef < BaseDef # , FixWxPrefix):

      class ParamMapping
        class MapDef
          def initialize(mdef)
            if ::Array === mdef
              @rbtype, @rbname, @rbdoc = mdef
            else
              mdef, @rbdoc = mdef.split('#')
              @rbdoc.strip!
              mdlist = mdef.strip.split(' ')
              @rbname = mdlist.pop
              @rbtype = mdlist.join(' ')
            end
          end

          def map
            {name: @rbname, type: @rbtype, doc: @rbdoc}
          end
        end

        def initialize(from, to)
          @from = (::Array === from ? from : [from]).collect do |argmask|
            if ParamDef::Mask === argmask
              argmask
            else
              ParamDef::Mask.new(argmask)
            end
          end
          @to = (::Array === to ? to : [to]).collect do |argdef|
            if MapDef === argdef
              argdef
            else
              MapDef.new(argdef)
            end
          end
        end

        def from_count
          @from.size
        end

        def get_mapped
          @to.collect { |e| e.map }
        end

        def matches?(paramdefs)
          @from.each_with_index do |mask, ix|
            return false if ix >= paramdefs.size || mask != paramdefs[ix]
          end
          true
        end
      end

      include Util::StringUtil

      def initialize(element = nil, **kwargs)
        super()
        @type = nil
        @definition = ''
        @template_params = [] # function is a template
        @args_string = ''
        @is_overloaded = false
        @overloads = []

        update_attributes(**kwargs)
        extract(element) if element
      end

      attr_accessor :type, :definition, :template_params, :args_string, :is_overloaded, :overloads

      def is_template?
        !template_params.empty?
      end

      def extract(element)
        super
        @type = BaseDef.flatten_node(element.at_xpath('type'))
        @definition = element.at_xpath('definition').text
        element.xpath('templateparamlist/param').each do |node|
          if node.at_xpath('declname')
            txt = node.at_xpath('declname').text
          else
            txt = node.at_xpath('type').text
            txt.sub!('class ', '')
            txt.sub!('typename ', '')
          end
          @template_params << txt
        end
        @args_string = element.at_xpath('argsstring').text
        check_deprecated
        element.xpath('param').each do |node|
          p = ParamDef.new(node)
          items << p
          # TODO: Look at @detailedDoc and pull out any matching
          # parameter description items and assign that value as the
          # briefDoc for this ParamDef object.
        end
      end

      def parameters
        items.select {|i| ParamDef === i }
      end

      def rb_decl_name
        rb_method_name(name)
      end

      def rb_doc(clsdef, fnix, fncount)
        # get parameterlist docs (if any)
        params_doc = @detailed_doc.at_xpath('para/parameterlist[@kind="param"]')
        # get detailed doc text without params doc
        doc = if params_doc
                @detailed_doc.text.sub(params_doc.text, '').strip
              else
                @detailed_doc.text.strip
              end.split("\n")
        # get mapped ruby parameter list
        param_defs = parameters
        params = []
        until param_defs.empty?
          # check for param mapping at current pos in param list, either class defined
          if (mapping = clsdef.find_param_mapping(param_defs) ||
                BaseDef.find_param_mapping(param_defs)) # or globally
            # remove mapped param definitions
            param_defs.shift(mapping.from_count)
            # store mapping
            params.concat mapping.get_mapped
          else
            # get param def at current pos
            paramdef = param_defs.shift
            # store param name with rb type mapped from wx typedefs
            rb_type = BaseDef.wx_type_to_rb(paramdef.type)
            rb_type = rb_type.join(',') if ::Array === rb_type
            params << {name: rb_param_name(paramdef.name), type: rb_type}
            if paramdef.default
              params.last[:default] = rb_constant_value(paramdef.default)
            end
          end
        end
        # find and add any parameter specific doc
        params_doc.xpath('parameteritem').each do |pi|
          if (pinm = pi.at_xpath('parameternamelist/parametername'))
            pinm = pinm.text
            # look up matching mapped param entry
            if (param = params.detect { |p| p[:name] == pinm })
              # add doc
              param[:doc] = pi.xpath('parameterdescription').text.strip
            end
          end
        end if params_doc
        # collect full function docs
        rb_doc = []
        paramlist = params.collect {|p| p[:default] ? "#{p[:name]}=#{p[:default]}" : p[:name]}.join(', ')
        if fncount>1
          rb_doc << "@!method #{rb_decl_name}(*args)" if fnix==0
          rb_doc << "@overload #{rb_decl_name}(#{paramlist})"
        else
          rb_doc << "@!method #{rb_decl_name}(#{paramlist})"
        end
        rb_doc.concat(doc.collect { |ln| '  '+ln })
        params.each do |p|
          rb_doc << ('  @param '  << p[:name] << ' [' << p[:type] << '] ' << (p[:doc] ? ' '+p[:doc] : ''))
        end
        rb_doc << "  @return [#{rb_return_type}]"
      end

      def rb_return_type
        BaseDef.wx_type_to_rb(type)
      end

      def signature
        sig = "#{@type} #{name}"
        if parameters.empty?
          sig << '()'
        else
          sig << '(' << parameters.collect {|p| "#{p.type}#{p.array ? '[]' : ''}" }.join(',') << ')'
        end
        sig
      end

      def check_for_overload(methods)
        methods.each do |m|
          if m.is_a?(FunctionDef) && m.name == @name
            m.overloads << self
            m.is_overloaded = @is_overloaded = true
            return true
          end
        end
        false
      end

      def all
        [self] + overloads
      end

      def find_overload(matchText, isConst = nil, printSig = false)
        # Search for an overloaded method that has matchText in its C++ argsString.
        all.each do |o|
          puts(o.signature) if printSig
          if o.signature.index(matchText) && !o.ignored
            unless isConst
              return o
            else
              return o if o.is_const == isConst
            end
          end
        end
        nil
      end

      def has_overloads
        # Returns True if there are any overloads that are not ignored.
        overloads.any? { |o| !o.ignored }
      end

      def rename_overload(matchText, newName, **kwargs)
        # Rename the overload with matching matchText in the argsString to
        # newName. The overload is moved out of this function's overload list
        # and directly into the parent module or class so it can appear to be a
        # separate function.
        if self.respond_to?(:module)
          parent = @module
        else
          parent = @klass
        end
        item = find_overload(matchText)
        item.rb_name = newName
        item.update_attributes(**kwargs)

        unless item == self && !has_overloads # unless we're done and there actually is only one instance of this method
          if item == self
            # Make the first overload take the place of this node in the
            # parent, and then insert this item into the parent's list again
            _overloads = @overloads.sort { |o1, o2| o1.ignored ? (o2.ignored ? 0 : 1) : (o2.ignored ? -1 : 0) }
            first = _overloads.first
            @overloads = []
            _overloads.shift
            first.overloads = _overloads
            idx = parent.items.index(self)
            parent.items[idx] = first
            parent.insert_item_after(first, self)
          else
            # Just remove from the overloads list and insert it into the parent.
            overloads.delete(item)
            parent.insert_item_after(self, item)
          end
        end
        item
      end

      def ignore(val = true)
        # In addition to ignoring this item, reorder any overloads to ensure
        # the primary overload is not ignored, if possible.
        super
        if @ignored and @overloads
          reorder_overloads
        end
        self
      end

      def reorder_overloads
        # Reorder a set of overloaded functions such that the primary
        # FunctionDef is one that is not ignored.
        if @overloads && ignored
          all_overloads = [self] + @overloads
          all_overloads.sort { |i1, i2| i1.ignored ? (i2.ignored ? 0 : 1) : (i2.ignored ? -1 : 0) }
          first = all_overloads.shift
          unless first.ignored
            if self.respond_to?(:module)
              parent = @module
            else
              parent = @klass
            end
            @overloads = []
            first.overloads = all_overloads
            idx = parent.items.index(self)
            parent.items[idx] = first
          end
        end
      end

      def _find_items
        _items = @items.dup
        @overloads.each do |o|
          _items.concat(o.items)
        end
        _items
      end

    end # class FunctionDef

    # Represents a class method, ctor or dtor declaration.
    class MethodDef < FunctionDef
      def initialize(element = nil, className = nil, **kwargs)
        super()
        @class_name = className
        @is_virtual = false
        @is_pure_virtual = false
        @is_override = false
        @is_static = false
        @is_const = false
        @is_ctor = false
        @is_dtor = false
        @is_operator = false
        @protection = 'public'
        update_attributes(**kwargs)
        extract(element) if element
        # elif not hasattr(self, 'isCore'):
        #     @isCore = _globalIsCore
      end

      attr_accessor :class_name, :is_virtual, :is_pure_virtual, :is_override, :is_static, :is_const, :is_ctor, :is_dtor,
                    :is_operator, :protection

      VALID_UNARY_OPERATORS = %w{~ + -}
      VALID_BINARY_OPERATORS =%w{[] + - * / % << >> & | ^ <= < > >= ==}

      def extract(element)
        super
        @is_static = element['static'] == 'yes'
        @is_virtual = %w[virtual pure-virtual].include?(element['virt'])
        @is_pure_virtual = (element['virt'] == 'pure-virtual')
        @is_override = !!element.at_xpath('reimplements')
        @is_const = (element['const'] == 'yes')
        @is_ctor = (@name == @class_name)
        @is_dtor = (@name == "~#{@class_name}")
        if (@is_operator = (@name.index('operator') == 0))
          if items.empty?           # no params : unary?
            self.ignore unless VALID_UNARY_OPERATORS.include?(@name.sub('operator', '').strip)
          elsif items.size == 1     # 1 param : binary?
            self.ignore unless VALID_BINARY_OPERATORS.include?(@name.sub('operator', '').strip)
          else  # must be operator function outside class
            self.ignore
          end
        end
        @protection = element['prot']
        unless %w[public protected].include?(@protection)
          raise ExtractorError.new("Invalid protection [#{@protection}")
        end
        # TODO: Should protected items be ignored by default or should we
        #       leave that up to the tweaker code or the generators?
        self.ignore if @protection == 'protected'
      end

      def rb_return_type
        if is_ctor
          rb_constant_name(class_name)
        else
          super
        end
      end

      def rb_decl_name
        if is_ctor
          'initialize'
        else
          "#{is_static ? 'self.' : ''}#{super}"
        end
      end

      def signature
        sig = super
        sig << ' const' if is_const
        sig
      end

    end # class MethodDef

    # A parameter of a function or method.
    class ParamDef < BaseDef

      class Mask
        RE = /\A(\*|&)([_a-zA-Z]\w*)\Z/
        def initialize(maskdef)
          @array = false
          if ::Array === maskdef
            @ctype, @name_mask, arr = maskdef
            @array = (arr == '[]' || arr == true) if arr
            if @name_mask.end_with?('[]')
              @array = true
              @name_mask = @name_mask[0..-3]
            end
          else
            mdlist = maskdef.to_s.split(' ')
            @name_mask = mdlist.pop
            if @name_mask == '[]' || @name_mask.end_with?('[]')
              @array = true
              @name_mask = (@name_mask == '[]' ? mdlist.pop : @name_mask[0..-3])
            end
            @ctype = mdlist.join(' ')
            RE.match(@name_mask) do |md|
              @ctype << md[1]
              @name_mask = md[2]
            end
            @ctype.tr!(' ','')
          end
        end

        def ==(paramdef)
          if paramdef.type.tr(' ','') == @ctype && paramdef.array == @array
            if ::Regexp === @name_mask
              return @name_mask =~ paramdef.name
            elsif @name_mask.end_with?('*')
              return paramdef.name.start_with?(@name_mask[0..-2])
            else
              return @name_mask.to_s == paramdef.name
            end
          end
          false
        end
      end

      def initialize(element = nil, **kwargs)
        super()
        @type = '' # data type
        @array = nil
        @default = nil # default value
        # @out = false # is it an output arg?
        # @in_out = false # is it both input and output?
        update_attributes(**kwargs)
        extract(element) if element
      end

      attr_accessor :type, :array, :default

      def extract(element)
        begin
          @type = BaseDef.flatten_node(element.at_xpath('type'))
          # we've got varags
          if @type == '...'
            @name = ''
          else
            if element.at_xpath('declname')
              @name = element.at_xpath('declname').text
            elsif element.at_xpath('defname')
              @name = element.at_xpath('defname').text
            end
            if element.at_xpath('array')
              @array = true
            end
            if element.at_xpath('defval')
              @default = BaseDef.flatten_node(element.at_xpath('defval'))
            end
          end
        rescue Exception
            puts("error when parsing element: #{element.to_s}")
            raise
        end
      end
    end # class ParamDef

  end # module Extractor

end # module WXRuby3
