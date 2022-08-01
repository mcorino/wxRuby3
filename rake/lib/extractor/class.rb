#--------------------------------------------------------------------
# @file    class.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface extractor
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

module WXRuby3

  module Extractor

    # The information about a class that is needed to generate wrappers for it.
    class ClassDef < BaseDef
      NAME_TAG = 'compoundname'

      def initialize(element = nil, kind = 'class', **kwargs)
        super()
        @kind = kind
        @protection = 'public'
        @template_params = [] # class is a template
        @bases = [] # base class names
        @sub_classes = [] # sub classes
        @hierarchy = {}
        # @node_bases = [] # for the inheritance diagram
        @enum_file = '' # To link sphinx output classes to enums
        @includes = [] # .h file for this class
        @abstract = false # is it an abstract base class?
        @external = false # class is in another module
        @no_def_ctor = false # do not generate a default constructor
        @singleton = false # class is a singleton so don't call the dtor until the interpreter exits
        @allow_auto_properties = true
        @header_code = []
        @cpp_code = []
        @convert_to_rb_object = nil
        @convert_from_rb_object = nil
        @allow_none = false # Allow the convertFrom code to handle nil too.
        @instance_code = nil # Code to be used to create new instances of this class
        @innerclasses = []
        @is_inner = false # Is this a nested class?
        @klass = nil # if so, then this is the outer class
        @pre_method_code = nil
        @post_process_re_st = nil

        # Stuff that needs to be generated after the class instead of within
        # it. Some back-end generators need to put stuff inside the class, and
        # others need to do it outside the class definition. The generators
        # can move things here for later processing when they encounter those
        # items.
        @generate_after_class = []

        update_attributes(**kwargs)
        extract(element) if element
      end

      attr_accessor :kind, :protection, :template_params, :bases, :sub_classes, :hierarchy, :enum_file, :includes,
                    :abstract, :external, :no_def_ctor, :singleton, :allow_auto_properties, :header_code, :cpp_code,
                    :convert_to_rb_object, :convert_from_rb_object, :allow_none, :instance_code, :innerclasses,
                    :is_inner, :klass, :pre_method_code, :post_process_re_st

      def rename_class(newName)
        @rb_name = newName
        items.each do |item|
          if item.respond_to?(:class_name)
              item.class_name = newName
              item.overloads.each { |overload| overload.class_name = newName }
          end
        end
      end

      def get_hierarchy(element)
        clshier = {}
        index = {}
        # collect
        element.at_xpath('inheritancegraph').xpath('node'). each do |node|
          node_id = node['id']
          node_name = node.at_xpath('label').text
          node_bases = node.xpath('childnode').inject({}) { |hash, cn|  hash[cn['refid']] = nil; hash }
          index[node_id] = [node_name, node_bases]
          clshier = node_bases if @name == node_name
        end
        # resolve
        index.each_value do |(nm, nb)|
          nb.replace(nb.inject({}) {|h,(bid,_)| h[index[bid].first] = index[bid].last; h })
        end
        clshier
      end

      def find_base(bases, name)
        return bases[name] if bases.has_key?(name)
        bases.each_value do |childbases|
          if (base = find_base(childbases, name))
            return base
          end
        end
        nil
      end
      private :find_base

      def is_derived_from?(classname)
        !!find_base(@hierarchy, classname)
      end

      # def find_hierarchy(element, all_classes, specials, read)
      #   unless read
      #     fullname = @name
      #     specials = [fullname]
      #   else
      #     fullname = element.text
      #   end
      #
      #   baselist = []
      #
      #   if read
      #     refid = element['refid']
      #     return [all_classes, specials] unless refid
      #
      #     fname = File.join(Extractor.xml_dir, refid + '.xml')
      #     root = File.open(fname) { |f| Nokogiri::XML(f).root }
      #     compounds = root.xpath('basecompoundref')
      #   else
      #     compounds = element.xpath('basecompoundref')
      #   end
      #
      #   compounds.each { |c| baselist << c.text }
      #
      #   all_classes[fullname] = [fullname, baselist]
      #
      #   compounds.each { |c| all_classes, specials = self.find_hierarchy(c, all_classes, specials, true) }
      #
      #   [all_classes, specials]
      # end

      def extract(element)
        super

        check_deprecated
        # @node_bases = find_hierarchy(element, {}, [], false)
        @hierarchy = get_hierarchy(element)

        element.xpath('basecompoundref').each { |node| @bases << node.text }
        element.xpath('derivedcompoundref').each { |node| @sub_classes << node.text }
        element.xpath('includes').each { |node| @includes << node.text }
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

        element.xpath('innerclass').each do |node|
          unless node['prot'] == 'private'
            ref = node['refid']
            fname = File.join(Extractor.xml_dir, ref + '.xml')
            root = File.open(fname) { |f| Nokogiri::XML(f).root }
            innerclass = root.elements.first
            kind = innerclass['kind']
            unless %w[class struct].include?(kind)
              raise ExtractorError.new("Invalid innerclass kind [#{kind}]")
            end
            item = ClassDef.new(innerclass, kind)
            item.protection = node['prot']
            item.is_inner = true
            item.klass = self # This makes a reference cycle but it's okay
            @innerclasses << item
          end
        end

        # TODO: Is it possible for there to be memberdef's w/o a sectiondef?
        element.xpath('sectiondef/memberdef').each do |node|
          # skip any private items
          unless node['prot'] == 'private'
            _kind = node['kind']
            if _kind == 'function'
              Extractor.extracting_msg(_kind, node)
              m = MethodDef.new(node, self.name, klass: self)
              @abstract = true if m.is_pure_virtual
              unless m.check_for_overload(self.items)
                self.items << m
              end
            elsif _kind == 'variable'
              Extractor.extracting_msg(_kind, node)
              v = MemberVarDef.new(node)
              self.items << v
            elsif _kind == 'enum'
              Extractor.extracting_msg(_kind, node)
              e = EnumDef.new(node, [self])
              self.items << e
            elsif _kind == 'typedef'
              Extractor.extracting_msg(_kind, node)
              t = TypedefDef.new(node)
              self.items << t
            elsif kind == 'friend'
              # noop
            else
              raise ExtractorError.new('Unknown memberdef kind: %s' % kind)
            end
          end
        end

        # make abstract unless the class has at least 1 public ctor
        ctor = self.items.find {|m| ClassDef === m && m.is_ctor }
        unless ctor && (ctor.protection == 'public' || ctor.overloads.any? {|ovl| ovl.protection == 'public' })
          @abstract = true
        end
      end

      def _find_items
        self.items + self.innerclasses
      end

    #   def addHeaderCode(self, code):
    #         if isinstance(code, list):
    #             self.headerCode.extend(code)
    #         else:
    #             self.headerCode.append(code)
    #
    #     def addCppCode(self, code):
    #         if isinstance(code, list):
    #             self.cppCode.extend(code)
    #         else:
    #             self.cppCode.append(code)
    #
    #
    #     def includeCppCode(self, filename):
    #         with textfile_open(filename) as fid:
    #             self.addCppCode(fid.read())
    #
    #
    #     def addAutoProperties(self):
    #         """
    #         Look at MethodDef and PyMethodDef items and generate properties if
    #         there are items that have Get/Set prefixes and have appropriate arg
    #         counts.
    #         """
    #         def countNonDefaultArgs(m):
    #             count = 0
    #             for p in m.items:
    #                 if not p.default and not p.ignored:
    #                     count += 1
    #             return count
    #
    #         def countPyArgs(item):
    #             count = 0
    #             args = item.argsString.replace('(', '').replace(')', '')
    #             for arg in args.split(','):
    #                 if arg != 'self':
    #                     count += 1
    #             return count
    #
    #         def countPyNonDefaultArgs(item):
    #             count = 0
    #             args = item.argsString.replace('(', '').replace(')', '')
    #             for arg in args.split(','):
    #                 if arg != 'self' and '=' not in arg:
    #                     count += 1
    #             return count
    #
    #         props = dict()
    #         for item in self.items:
    #             if isinstance(item, (MethodDef, PyMethodDef)) \
    #                and item.name not in ['Get', 'Set'] \
    #                and (item.name.startswith('Get') or item.name.startswith('Set')):
    #                 prefix = item.name[:3]
    #                 name = item.name[3:]
    #                 prop = props.get(name, PropertyDef(name))
    #                 if isinstance(item, PyMethodDef):
    #                     ok = False
    #                     argCount = countPyArgs(item)
    #                     nonDefaultArgCount = countPyNonDefaultArgs(item)
    #                     if prefix == 'Get' and argCount == 0:
    #                         ok = True
    #                         prop.getter = item.name
    #                         prop.usesPyMethod = True
    #                     elif prefix == 'Set'and \
    #                          (nonDefaultArgCount == 1 or (nonDefaultArgCount == 0 and argCount > 0)):
    #                         ok = True
    #                         prop.setter = item.name
    #                         prop.usesPyMethod = True
    #
    #                 else:
    #                     # look at all overloads
    #                     ok = False
    #                     for m in item.all():
    #                         # don't use ignored or static methods for propertiess
    #                         if m.ignored or m.isStatic:
    #                             continue
    #                         if prefix == 'Get':
    #                             prop.getter = m.name
    #                             # Getters must be able to be called with no args, ensure
    #                             # that item has exactly zero args without a default value
    #                             if countNonDefaultArgs(m) != 0:
    #                                 continue
    #                             ok = True
    #                             break
    #                         elif prefix == 'Set':
    #                             prop.setter = m.name
    #                             # Setters must be able to be called with 1 arg, ensure
    #                             # that item has at least 1 arg and not more than 1 without
    #                             # a default value.
    #                             if len(m.items) == 0 or countNonDefaultArgs(m) > 1:
    #                                 continue
    #                             ok = True
    #                             break
    #                 if ok:
    #                     if hasattr(prop, 'usesPyMethod'):
    #                         prop = PyPropertyDef(prop.name, prop.getter, prop.setter)
    #                     props[name] = prop
    #
    #         if props:
    #             self.addPublic()
    #         for name, prop in sorted(props.items()):
    #             # properties must have at least a getter
    #             if not prop.getter:
    #                 continue
    #             starts_with_number = False
    #             try:
    #                 int(name[0])
    #                 starts_with_number = True
    #             except:
    #                 pass
    #
    #             # only create the prop if a method with that name does not exist, and it is a valid name
    #             if starts_with_number:
    #                 print('WARNING: Invalid property name %s for class %s' % (name, self.name))
    #             elif self.findItem(name):
    #                 print("WARNING: Method %s::%s already exists in C++ class API, can not create a property." % (self.name, name))
    #             else:
    #                 self.items.append(prop)
    #
    #
    #
    #
    #     def addProperty(self, *args, **kw):
    #         """
    #         Add a property to a class, with a name, getter function and optionally
    #         a setter method.
    #         """
    #         # As a convenience allow the name, getter and (optionally) the setter
    #         # to be passed as a single string. Otherwise the args will be passed
    #         # as-is to PropertyDef
    #         if len(args) == 1:
    #             name = getter = setter = ''
    #             split = args[0].split()
    #             assert len(split) in [2 ,3]
    #             if len(split) == 2:
    #                 name, getter = split
    #             else:
    #                 name, getter, setter = split
    #             p = PropertyDef(name, getter, setter, **kw)
    #         else:
    #             p = PropertyDef(*args, **kw)
    #         self.items.append(p)
    #         return p
    #
    #
    #
    #     def addPyProperty(self, *args, **kw):
    #         """
    #         Add a property to a class that can use PyMethods that have been
    #         monkey-patched into the class. (This property will also be
    #         jammed in to the class in like manner.)
    #         """
    #         # Read the nice comment in the method above.  Ditto.
    #         if len(args) == 1:
    #             name = getter = setter = ''
    #             split = args[0].split()
    #             assert len(split) in [2 ,3]
    #             if len(split) == 2:
    #                 name, getter = split
    #             else:
    #                 name, getter, setter = split
    #             p = PyPropertyDef(name, getter, setter, **kw)
    #         else:
    #             p = PyPropertyDef(*args, **kw)
    #         self.items.append(p)
    #         return p
    #
    #     #------------------------------------------------------------------
    #
    #     def _addMethod(self, md, overloadOkay=True):
    #         md.klass = self
    #         if overloadOkay and self.findItem(md.name):
    #             item = self.findItem(md.name)
    #             item.overloads.append(md)
    #             item.reorderOverloads()
    #         else:
    #             self.items.append(md)
    #
    #
    #     def addCppMethod(self, type, name, argsString, body, doc=None, isConst=False,
    #                      cppSignature=None, overloadOkay=True, **kw):
    #         """
    #         Add a new C++ method to a class. This method doesn't have to actually
    #         exist in the real C++ class. Instead it will be grafted on by the
    #         back-end wrapper generator such that it is visible in the class in the
    #         target language.
    #         """
    #         md = CppMethodDef(type, name, argsString, body, doc, isConst, klass=self,
    #                           cppSignature=cppSignature, **kw)
    #         self._addMethod(md, overloadOkay)
    #         return md
    #
    #
    #     def addCppCtor(self, argsString, body, doc=None, noDerivedCtor=True,
    #                    useDerivedName=False, cppSignature=None, **kw):
    #         """
    #         Add a C++ method that is a constructor.
    #         """
    #         md = CppMethodDef('', self.name, argsString, body, doc=doc,
    #                           isCtor=True, klass=self, noDerivedCtor=noDerivedCtor,
    #                           useDerivedName=useDerivedName, cppSignature=cppSignature, **kw)
    #         self._addMethod(md)
    #         return md
    #
    #
    #     def addCppDtor(self, body, useDerivedName=False, **kw):
    #         """
    #         Add a C++ method that is a destructor.
    #         """
    #         md = CppMethodDef('', '~'+self.name, '()', body, isDtor=True, klass=self,
    #                           useDerivedName=useDerivedName, **kw)
    #         self._addMethod(md)
    #         return md
    #
    #
    #     def addCppMethod_sip(self, type, name, argsString, body, doc=None, **kw):
    #         """
    #         Just like the above but can do more things that are SIP specific in
    #         the code body, instead of using the general purpose implementation.
    #         """
    #         md = CppMethodDef_sip(type, name, argsString, body, doc, klass=self, **kw)
    #         self._addMethod(md)
    #         return md
    #
    #     def addCppCtor_sip(self, argsString, body, doc=None, noDerivedCtor=True,
    #                        cppSignature=None, **kw):
    #         """
    #         Add a C++ method that is a constructor.
    #         """
    #         md = CppMethodDef_sip('', self.name, argsString, body, doc=doc,
    #                           isCtor=True, klass=self, noDerivedCtor=noDerivedCtor,
    #                           cppSignature=cppSignature, **kw)
    #         self._addMethod(md)
    #         return md
    #
    #     #------------------------------------------------------------------
    #
    #
    #     def addPyMethod(self, name, argsString, body, doc=None, **kw):
    #         """
    #         Add a (monkey-patched) Python method to this class.
    #         """
    #         pm = PyMethodDef(self, name, argsString, body, doc, **kw)
    #         self.items.append(pm)
    #         return pm
    #
    #
    #     def addPyCode(self, code):
    #         """
    #         Add a snippet of Python code which is to be associated with this class.
    #         """
    #         pc = PyCodeDef(code, klass=self, protection = 'public')
    #         self.items.append(pc)
    #         return pc
    #
    #
    #     def addPublic(self, code=''):
    #         """
    #         Adds a 'public:' protection keyword to the class, optionally followed
    #         by some additional code.
    #         """
    #         text = 'public:'
    #         if code:
    #             text = text + '\n' + code
    #         self.addItem(WigCode(text))
    #
    #     def addProtected(self, code=''):
    #         """
    #         Adds a 'protected:' protection keyword to the class, optionally followed
    #         by some additional code.
    #         """
    #         text = 'protected:'
    #         if code:
    #             text = text + '\n' + code
    #         self.addItem(WigCode(text))
    #
    #
    #     def addPrivate(self, code=''):
    #         """
    #         Adds a 'private:' protection keyword to the class, optionally followed
    #         by some additional code.
    #         """
    #         text = 'private:'
    #         if code:
    #             text = text + '\n' + code
    #         self.addItem(WigCode(text))
    #
    #
    #     def addDefaultCtor(self, prot='protected'):
    #         # add declaration of a default constructor to this class
    #         wig = WigCode("""\
    # {PROT}:
    #     {CLASS}();""".format(CLASS=self.name, PROT=prot))
    #         self.addItem(wig)
    #
    #     def addCopyCtor(self, prot='protected'):
    #         # add declaration of a copy constructor to this class
    #         wig = WigCode("""\
    # {PROT}:
    #     {CLASS}(const {CLASS}&);""".format(CLASS=self.name, PROT=prot))
    #         self.addItem(wig)
    #
    #     def addPrivateCopyCtor(self):
    #         self.addCopyCtor('private')
    #
    #     def addPrivateDefaultCtor(self):
    #         self.addDefaultCtor('private')
    #
    #     def addPrivateAssignOp(self):
    #         # add declaration of an assignment opperator to this class
    #         wig = WigCode("""\
    # private:
    #     {CLASS}& operator=(const {CLASS}&);""".format(CLASS=self.name))
    #         self.addItem(wig)
    #
    #     def addDtor(self, prot='protected', isVirtual=False):
    #         # add declaration of a destructor to this class
    #         virtual = 'virtual ' if isVirtual else ''
    #         wig = WigCode("""\
    # {PROT}:
    #     {VIRTUAL}~{CLASS}();""".format(VIRTUAL=virtual, CLASS=self.name, PROT=prot))
    #         self.addItem(wig)
    #
    #     def addDefaultCtor(self, prot='protected'):
    #         # add declaration of a default constructor to this class
    #         wig = WigCode("""\
    # {PROT}:
    #     {CLASS}();""".format(CLASS=self.name, PROT=prot))
    #         self.addItem(wig)
    #
    #     def mustHaveApp(self, value=True):
    #         if value:
    #             self.preMethodCode = "if (!wxPyCheckForApp()) return NULL;\n"
    #         else:
    #             self.preMethodCode = None
    #
    #
    #     def copyFromClass(self, klass, name):
    #         """
    #         Copy an item from another class into this class. If it is a pure
    #         virtual method in the other class then assume that it has a concrete
    #         implementation in this class and change the flag.
    #
    #         Returns the new item.
    #         """
    #         item = copy.deepcopy(klass.find(name))
    #         if isinstance(item, MethodDef) and item.isPureVirtual:
    #             item.isPureVirtual = False
    #         self.addItem(item)
    #         return item
    #
    #     def setReSTPostProcessor(self, func):
    #         """
    #         Set a function to be called after the class's docs have been generated.
    #         """
    #         self.postProcessReST = func

    end # class ClassDef

    # Use the C++ methods of a class to make a Ruby attribute.
    #
    # NOTE: This one is not automatically extracted, but can be added to
    #       classes in the tweaker stage
    class PropertyDef < BaseDef
      def initialize(name, getter = nil, setter = nil, doc = nil, **kwargs)
        super()
        @name = name
        @getter = getter
        @setter = setter
        @brief_doc = doc
        @protection = 'public'
        update_attributes(**kwargs)
      end
    end # class PropertyDef

    class RbPropertyDef < PropertyDef; end

  end # module Extractor

end # module WXRuby3
