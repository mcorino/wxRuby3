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
        @includes = [] # .h file for this class
        @abstract = false # is it an abstract base class?
        @no_def_ctor = false # do not generate a default constructor
        @innerclasses = []
        @is_inner = false # Is this a nested class?
        @klass = nil # if so, then this is the outer class
        @event = false # if so, is wxEvent derived class
        @event_emitter = false # if so, class has emitted events specified
        @event_types = []

        update_attributes(**kwargs)
        extract(element) if element
      end

      attr_accessor :kind, :protection, :template_params, :bases, :sub_classes, :hierarchy, :includes,
                    :abstract, :no_def_ctor, :innerclasses, :is_inner, :klass, :event, :event_emitter, :event_types

      def is_template?
        !template_params.empty?
      end

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
        graph = element.at_xpath('inheritancegraph')
        if graph
          graph.xpath('node'). each do |node|
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

        if is_derived_from?('wxEvent')
          @event = true
          if detailed_doc.text.index('Event macros:')
            detailed_doc.xpath('.//listitem').each do |li|
              if li.text =~ /(EVT_\w+)\((.*)\)/
                evt_handler = $1
                args = $2.split(',').collect {|a| a.strip }
                # skip event macros with event type argument
                unless args.any? { |a| a == 'event' }
                  # determine evt_type handled
                  evt_type = if li.text =~ /Process\s+a\s+wx(\w+)\s+/
                               $1
                             else
                               evt_handler
                             end
                  # record event handler (macro) name, event type handled and the number of event id arguments
                  evt_arity = args.inject(0) {|c, a| c += 1 if a.start_with?('id'); c }
                  @event_types << [evt_handler, evt_type, evt_arity]
                end
              end
            end
          end
        else
          evt_heading = detailed_doc.xpath('.//heading').find {|h| h.text == 'Events emitted by this class'}
          if evt_heading
            @event_emitter = true
            evt_paras = evt_heading.xpath('parent::para').first.xpath('following-sibling::para')
            if evt_paras.size>1 &&
                evt_paras.first.text.start_with?('The following event handler macros redirect') &&
                (evt_ref = evt_paras.first.at('./ref'))
              evt_klass = evt_ref.text
              if evt_paras[1].text.index('Event macros for events emitted by this class:')
                evt_paras[1].xpath('.//listitem').each do |li|
                  if li.text =~ /(EVT_\w+)\((.*)\)/
                    evt_handler = $1
                    args = $2.split(',').collect {|a| a.strip }
                    # skip event macros with event type argument
                    unless args.any? { |a| a == 'event' }
                      # determine evt_type handled
                      evt_type = if li.text =~ /Process\s+a\s+wx(\w+)\s+/
                                   $1
                                 else
                                   evt_handler
                                 end
                      # record event handler (macro) name, event type handled and the number of event id arguments
                      evt_arity = args.inject(0) {|c, a| c += 1 if a.start_with?('id'); c }
                      @event_types << [evt_handler, evt_type, evt_arity, evt_klass]
                    end
                  end
                end
              end
            end
          end
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
        ctor = self.items.find {|m| MethodDef === m && m.is_ctor }
        unless ctor && (ctor.protection == 'public' || ctor.overloads.any? {|ovl| ovl.protection == 'public' })
          @abstract = true
        end
      end

      def methods
        ::Enumerator.new { |y| items.each {|i|  y << i if MethodDef === i }}
      end

      def all_methods
        ::Enumerator::Chain.new(*methods.collect {|m| m.all })
      end

      def _find_items
        self.items + self.innerclasses
      end

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
