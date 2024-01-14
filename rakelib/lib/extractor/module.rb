# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface extractor
###

module WXRuby3

  module Extractor

    # This class holds all the items that will be in the generated module
    class ModuleDef < BaseDef
      def initialize(package, modname, name, gendoc: false)
        super()
        @package = package
        @module_name = modname
        @name = name
        @header_code = []
        @cpp_code = []
        @initializer_code = []
        @pre_initializer_code = []
        @post_initializer_code = []
        @is_a_real_module = (module_name == name)
        @gendoc = gendoc
      end

      attr_accessor :package, :module_name, :header_code, :cpp_code, :initializer_code,
                    :pre_initializer_code, :post_initializer_code, :is_a_real_module, :gendoc

      # Called after the loading of items from the XML has completed, just
      # before the tweaking stage is done.
      def parse_completed
        # Reorder the items in the module to be a little more sane, such as
        # enums and other constants first, then the classes and functions (since
        # they may use those constants) and then the global variables, but perhaps
        # only those that have classes in this module as their type.
        one = []
        two = []
        three = []
        self.items.each do |item|
          case item
          when ClassDef, FunctionDef
            two << item
          when GlobalVarDef
            if BaseDef.guess_type_int(item) ||
              BaseDef.guess_type_float(item) ||
              BaseDef.guess_type_str(item)
              one << item
            else
              three << item
            end
            # template instantiations go at the end

          when TypedefDef
            if item.type.index('<')
              three << item
            else
              one << item
            end
          else
            one << item
          end
        end
        self.items = one + two + three
      end

      def add_element(element)
        item = nil
        kind = element['kind']
        case kind
        when 'class'
          Extractor.extracting_msg(kind, element, ClassDef::NAME_TAG)
          item = ClassDef.new(element, gendoc: @gendoc)
          self.items << item

        when 'struct'
          Extractor.extracting_msg(kind, element, ClassDef::NAME_TAG)
          item = ClassDef.new(element, kind: 'struct', gendoc: @gendoc)
          self.items << item

        when 'function'
          Extractor.extracting_msg(kind, element)
          item = FunctionDef.new(element, gendoc: @gendoc)
          self.items << item unless item.check_for_overload(self.items)

        when 'enum'
          Extractor.extracting_msg(kind, element)
          item = EnumDef.new(element, gendoc: @gendoc)
          self.items << item

        when 'variable'
          Extractor.extracting_msg(kind, element)
          item = GlobalVarDef.new(element, gendoc: @gendoc)
          self.items << item

        when 'typedef'
          Extractor.extracting_msg(kind, element)
          item = TypedefDef.new(element, gendoc: @gendoc)
          self.items << item

        when 'define'
          # if it doesn't have a value, it must be a macro.
          value = BaseDef.flatten_node(element.at_xpath("initializer"))
          unless value
            Extractor.skipping_msg(kind, element)
          else
            # NOTE: This assumes that the #defines are numeric values.
            # There will have to be some tweaking done for items that are
            # not numeric...
            Extractor.extracting_msg(kind, element)
            item = DefineDef.new(element, gendoc: @gendoc)
            self.items << item
          end

        when 'file', 'namespace'
          Extractor.extracting_msg(kind, element, 'compoundname')
          element.xpath('sectiondef/memberdef').each { |node| self.add_element(node) }
          # from doxygen 1.9.7 onwards some members are not included in the same XML file
          # but referenced from another XML file; so we need to resolve such references
          # and than add the resolved element
          element.xpath('sectiondef/member').each do |node|
            node = self.resolveRefId(node)
            self.add_element(node)
          end

        else
          raise ExtractorError.new('Unknown module item kind: %s' % kind)
        end
        item
      end

      def resolveRefId(node)
        refid = node['refid'].split('_')
        refid.pop
        fname = File.join(Extractor.xml_dir, refid.join('_')+'.xml')
        root = File.open(fname) {|f| Nokogiri::XML(f) }.root
        root.at_xpath(".//sectiondef/memberdef[@id='#{node['refid']}']")
      end

      # Add a new C++ function into the module that is written by hand, not
      # wrapped.
      def add_cpp_function(type, name, argsString, body, doc = nil, **kwargs)
        md = CppMethodDef.new(type, name, argsString, body, doc, **kwargs)
        self.items << md
        md
      end

      def classes
        ::Enumerator.new { |y| items.each {|i| y << i if ClassDef === i}}
      end

    end # class ModuleDef

  end # module Extractor

end # module WXRuby3
