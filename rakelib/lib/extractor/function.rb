###
# wxRuby3 wxWidgets interface extractor
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  module Extractor

    # Information about a standalone function.
    class FunctionDef < BaseDef

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

      def parameter_count
        items.inject(0) { |c, i| c += 1 if ParamDef === i; c }
      end

      def required_param_count
        items.inject(0) { |c, i| c += 1 if ParamDef === i && !i.default; c }
      end

      def rb_decl_name
        "self.#{rb_method_name(rb_name || name)}"
      end

      def rb_doc(xml_trans, type_maps)
        ovls = all.select {|m| !m.docs_ignored && !m.deprecated }
        ovl_docs = ovls.collect { |mo| mo.rb_doc_decl(xml_trans, type_maps) }
        ovl_docs.inject({}) do |docs, (name, params, doc)|
          if docs.has_key?(name)
            docs[name] << [params, doc]
          else
            docs[name] = [[params, doc]]
          end
          docs
        end
      end

      def rb_doc_decl(xml_trans, type_maps)
        # get parameterlist docs (if any)
        params_doc = @detailed_doc.at_xpath('para/parameterlist[@kind="param"]')
        # unlink params_doc if any
        params_doc.unlink if params_doc
        # get brief doc
        doc = xml_trans.to_doc(@brief_doc)
        # add detailed doc text without params doc
        doc << xml_trans.to_doc(@detailed_doc)
        # get mapped ruby parameter list
        params = []
        mapped_ret_args = nil
        param_defs = self.parameters
        unless param_defs.empty?
          # map parameters
          mapped_args, mapped_ret_args = type_maps.map_input(param_defs.dup)
          # collect full param specs
          mapped_args.each do |arg|
            paramdef = param_defs[arg.index]
            pnm = if paramdef.name.empty?
                    "arg#{params.size > 0 ? params.size.to_s : ''}"
                  else
                    rb_param_name(paramdef.name)
                  end
            params << { name: pnm, type: arg.type }
            if paramdef.default
              defexp = rb_constant_expression(paramdef.default)
              # in case the default expression dereferences a pointer or passes an address clean it up
              defexp.sub!(/\A\s*[\*\&]/, '')
              # in case the default expression contains anything else but simple numbers or identifiers, wrap in ()
              params.last[:default] = if /\A([\d\-\+\.]+|[\w:]+)\Z/ =~ defexp
                                        defexp
                                      else
                                        "(#{defexp})"
                                      end
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
              param[:doc] = xml_trans.to_doc(pi.xpath('parameterdescription')).lstrip
            end
          end
        end if params_doc
        # collect full function docs
        paramlist = params.collect {|p| p[:default] ? "#{p[:name]}=#{p[:default]}" : p[:name]}.join(', ').strip
        doclns = doc.split("\n")
        params.each do |p|
          doclns << ('@param '  << p[:name] << ' [' << p[:type] << '] ' << (p[:doc] ? ' '+(p[:doc].split("\n").join("\n  ")) : ''))
        end
        result = [rb_return_type(type_maps)]
        result.concat(mapped_ret_args.collect { |mra| mra.type }) if mapped_ret_args
        result.compact! # remove nil values (possible ignored output)
        case result.size
        when 0
          doclns << "@return [void]"
        when 1
          doclns << "@return [#{result.first}]"
        else
          doclns << "@return [Array(#{result.join(',')})]"
        end
        [rb_decl_name, paramlist, doclns]
      end

      def rb_return_type(type_maps)
        mapped_type = type_maps.map_output(type)
        (mapped_type.empty? || mapped_type == 'void') ? nil : mapped_type
      end

      def argument_list
        parameters.collect {|p| "#{p.type}#{p.array ? '[]' : ''}" }.join(',')
      end

      def signature
        sig = "#{@type} #{name}"
        if parameters.empty?
          sig << '()'
        else
          sig << '(' << argument_list << ')'
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
          sig = o.signature
          puts(sig) if printSig
          sig.tr!(' ', '')
          if sig.index(matchText)
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

      def ignore(val = true, ignore_doc: nil)
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
        @args_string.sub!(/\s*=0/, '') if @is_pure_virtual
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
      end

      def rb_return_type(type_maps)
        if is_ctor
          rb_wx_name(class_name)
        else
          super
        end
      end

      def rb_decl_name
        if is_ctor
          'initialize'
        else
          "#{is_static ? 'self.' : ''}#{rb_method_name(rb_name || name)}"
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

      def initialize(element = nil, **kwargs)
        super()
        @type = '' # data type
        @array = false
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
            @name = '*args'
          else
            if element.at_xpath('declname')
              @name = element.at_xpath('declname').text
            elsif element.at_xpath('defname')
              @name = element.at_xpath('defname').text
            end
            if element.at_xpath('array') && element.at_xpath('array').text.index('[')
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

      def to_s
        "#{@type} #{@name}#{@array ? ' []' : ''}"
      end
    end # class ParamDef

  end # module Extractor

end # module WXRuby3
