#--------------------------------------------------------------------
# @file    module.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface extractor
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

module WXRuby3

  module Extractor

    # This class holds all the items that will be in the generated module
    class ModuleDef < BaseDef
      def initialize(package, modname, name, docstring = '', check4unittest = true)
        super()
        @package = package
        @module_name = modname
        @name = name
        @docstring = docstring
        @check4unittest = check4unittest
        @header_code = []
        @cpp_code = []
        @initializer_code = []
        @pre_initializer_code = []
        @post_initializer_code = []
        @includes = []
        @imports = []
        @is_a_real_module = (module_name == name)
      end

      attr_accessor :package, :module_name, :docstring, :check4unittest, :header_code, :cpp_code, :initializer_code,
                    :pre_initializer_code, :post_initializer_code, :includes, :imports, :is_a_real_module

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

        # # give everything an isCore flag
        # global _globalIsCore
        # _globalIsCore = self.module == '_core'
        # for item in self.allItems():
        #     item.isCore = _globalIsCore
      end

      # def addHeaderCode(self, code):
      #     if isinstance(code, list):
      #         self.headerCode.extend(code)
      #     else:
      #         self.headerCode.append(code)
      #
      # def addCppCode(self, code):
      #     if isinstance(code, list):
      #         self.cppCode.extend(code)
      #     else:
      #         self.cppCode.append(code)
      #
      # def includeCppCode(self, filename):
      #     with textfile_open(filename) as fid:
      #         self.addCppCode(fid.read())
      #
      # def addInitializerCode(self, code):
      #     if isinstance(code, list):
      #         self.initializerCode.extend(code)
      #     else:
      #         self.initializerCode.append(code)
      #
      # def addPreInitializerCode(self, code):
      #     if isinstance(code, list):
      #         self.preInitializerCode.extend(code)
      #     else:
      #         self.preInitializerCode.append(code)
      #
      # def addPostInitializerCode(self, code):
      #     if isinstance(code, list):
      #         self.postInitializerCode.extend(code)
      #     else:
      #         self.postInitializerCode.append(code)

      def add_include(*names)
        self.includes.concat(names)
      end

      def add_import(*names)
        self.imports.concat(names)
      end

      def add_element(element)
        item = nil
        kind = element['kind']
        case kind
        when 'class'
          Extractor.extracting_msg(kind, element, ClassDef::NAME_TAG)
          item = ClassDef.new(element, module: self)
          self.items << item

        when 'struct'
          Extractor.extracting_msg(kind, element, ClassDef::NAME_TAG)
          item = ClassDef.new(element, kind: 'struct')
          self.items << item

        when 'function'
          Extractor.extracting_msg(kind, element)
          item = FunctionDef.new(element, module: self)
          self.items << item unless item.check_for_overload(self.items)

        when 'enum'
          in_class = []
          self.items.each { |el| in_class << el if el.is_a?(ClassDef) }
          Extractor.extracting_msg(kind, element)
          item = EnumDef.new(element, in_class)
          self.items << item

        when 'variable'
          Extractor.extracting_msg(kind, element)
          item = GlobalVarDef.new(element)
          self.items << item

        when 'typedef'
          Extractor.extracting_msg(kind, element)
          item = TypedefDef.new(element)
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
            item = DefineDef.new(element)
            self.items << item
          end

        when 'file', 'namespace'
          Extractor.extracting_msg(kind, element, 'compoundname')
          element.xpath('sectiondef/memberdef').each { |node| self.add_element(node) }

        else
          raise ExtractorError.new('Unknown module item kind: %s' % kind)
        end
        item
      end

      # Add a new C++ function into the module that is written by hand, not
      # wrapped.
      def add_cpp_function(type, name, argsString, body, doc = nil, **kwargs)
        md = CppMethodDef.new(type, name, argsString, body, doc, **kwargs)
        self.items << md
        md
      end

      # def addCppFunction_sip(self, type, name, argsString, body, doc=None, **kw):
      #     """
      #     Add a new C++ function into the module that is written by hand, not
      #     wrapped.
      #     """
      #     md = CppMethodDef_sip(type, name, argsString, body, doc, **kw)
      #     self.items.append(md)
      #     return md
      #
      #
      # def addPyCode(self, code, order=None, **kw):
      #     """
      #     Add a snippet of Python code to the wrapper module.
      #     """
      #     pc = PyCodeDef(code, order, **kw)
      #     self.items.append(pc)
      #     return pc


      # def addGlobalStr(self, name, before=None, wide=False):
      #     if self.findItem(name):
      #         self.findItem(name).ignore()
      #     if wide:
      #         gv = GlobalVarDef(type='const wchar_t*', name=name)
      #     else:
      #         gv = GlobalVarDef(type='const char*', name=name)
      #     if before is None:
      #         self.addItem(gv)
      #     elif isinstance(before, int):
      #         self.insertItem(before, gv)
      #     else:
      #         self.insertItemBefore(before, gv)
      #     return gv
      #
      #
      # def includePyCode(self, filename, order=None):
      #     """
      #     Add a snippet of Python code from a file to the wrapper module.
      #     """
      #     with textfile_open(filename) as fid:
      #         text = fid.read()
      #     return self.addPyCode(
      #         "#" + '-=' * 38 + '\n' +
      #         ("# This code block was included from %s\n%s\n" % (filename, text)) +
      #         "# End of included code block\n"
      #         "#" + '-=' * 38 + '\n'            ,
      #         order
      #         )


      # def addPyFunction(self, name, argsString, body, doc=None, order=None, **kw):
      #     """
      #     Add a Python function to this module.
      #     """
      #     pf = PyFunctionDef(name, argsString, body, doc, order, **kw)
      #     self.items.append(pf)
      #     return pf
      #
      #
      # def addPyClass(self, name, bases=[], doc=None, items=[], order=None, **kw):
      #     """
      #     Add a pure Python class to this module.
      #     """
      #     pc = PyClassDef(name, bases, doc, items, order, **kw)
      #     self.items.append(pc)
      #     return pc

    end # class ModuleDef

  end # module Extractor

end # module WXRuby3
