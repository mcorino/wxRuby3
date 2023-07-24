###
# wxRuby3 wxWidgets interface extractor
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  module Extractor

    # Represents a basic variable declaration.
    class VariableDef < BaseDef
      def initialize(element = nil, **kwargs)
        super()
        @type = nil
        @definition = ''
        @args_string = ''
        @no_setter = false
        @value = nil;
        update_attributes(**kwargs)
        extract(element) if element
      end

      attr_accessor :type, :definition, :args_string, :no_setter, :value

      def extract(element)
        super
        @type = BaseDef.flatten_node(element.at_xpath('type'))
        @definition = element.at_xpath('definition').text
        @args_string = element.at_xpath('argsstring').text
        @value = BaseDef.flatten_node(element.at_xpath('initializer'))
      end
    end # class VariableDef

    #---------------------------------------------------------------------------
    # These need the same attributes as VariableDef, but we use separate classes
    # so we can identify what kind of element it came from originally.

    class GlobalVarDef < VariableDef; end

    class TypedefDef < VariableDef
      def initialize(element = nil, **kwargs)
        super()
        @no_type_name = false
        @doc_as_class = false
        @bases = []
        @protection = 'public'
        update_attributes(**kwargs)
        extract(element) if element
      end

      attr_accessor :no_type_name, :doc_as_class, :bases, :protection
    end # class TypedefDef

    #---------------------------------------------------------------------------

    class MemberVarDef < VariableDef

      include Util::StringUtil

      # Represents a variable declaration in a class.
      def initialize(element = nil, **kwargs)
        super()
        @is_static = false
        @protection = 'public'
        @get_code = ''
        @set_code = ''
        update_attributes(**kwargs)
        extract(element) if element
      end

      attr_accessor :is_static, :protection, :get_code, :set_code

      def extract(element)
        super
        @is_static = (element['static'] == 'yes')
        @protection = element['prot']
        unless %w[public protected].include?(@protection)
          raise ExtractorError.new("Invalid protection [#{@protection}")
        end
        ignore # ignore all member variables by default (trust on availability of accessor methods)
      end

      def rb_return_type(type_maps, xml_trans)
        mapped_type = type_maps.map_output(type) || xml_trans.type_to_doc(type)
        mapped_type == 'void' ? nil : mapped_type
      end
      private :rb_return_type

      # collect Ruby doc for member var
      # SWIG generates an attribute reader and writer for these
      def rb_doc(xml_trans, type_maps)
        var_doc = ''
        # get brief doc
        var_doc = xml_trans.to_doc(@brief_doc) if @brief_doc
        # add detailed doc text without params doc
        var_doc << xml_trans.to_doc(@detailed_doc) if @detailed_doc
        doc = []
        # first document the reader
        doc << [var_doc.dup]
        doc.last << "@return [#{rb_return_type(type_maps, xml_trans)}]"
        doc << "def #{is_static ? 'self.' : ''}#{rb_method_name(rb_name || name)}; end"
        # next document the writer (if any)
        unless no_setter
          doc << [var_doc.dup]
          parms = [ParamDef.new(nil,
                                name: 'val',
                                type: type.dup,
                                array: false)]
          mapped_args, _ = type_maps.map_input(parms)
          if mapped_args.empty? # something went wrong!
            doc.last << "@param val [#{xml_trans.type_to_doc(type)}]"
          else
            doc.last << "@param val [#{mapped_args.first.type || xml_trans.type_to_doc(type)}]"
          end
          doc.last << "@return [void]"
          doc << "def #{is_static ? 'self.' : ''}#{rb_method_name(rb_name || name)}=(val); end"
        end
        doc
      end
    end # class MemberVarDef

    #---------------------------------------------------------------------------

    # Represents a #define with a name and a value.
    class DefineDef < BaseDef
      def initialize(element = nil, **kwargs)
        super()
        if element
          @name = element.at_xpath('name').text
          @value = BaseDef.flatten_node(element.at_xpath('initializer'))
          @macro = !element.xpath('param').empty?
        end
        update_attributes(**kwargs)
      end

      attr_reader :value

      def is_macro?
        @macro
      end
    end # class DefineDef

  end # module Extractor

end # module WXRuby3
