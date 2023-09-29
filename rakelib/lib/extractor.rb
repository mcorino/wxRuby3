# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface extractor
###

require 'nokogiri'
require 'set'

require_relative './config'
require_relative './util/string'

module WXRuby3

  module Extractor

    class ExtractorError < Exception; end

    class << self

      include Util::StringUtil

      class DoxyXMLError < Exception; end

      private

      def class_to_doxy_name(name, attempts, base='class')
        filename = base + simple_underscore!(name.dup)
        filename = File.join(xml_dir, filename + '.xml')
        attempts << filename
        filename
      end

      def include_to_doxy_name(name)
        name = name.sub('wx/', '')
        subdir = name.index('/') ? File.dirname(name) : ''
        name = File.basename(name).sub('.h', '_8h')
        unless subdir.empty?
          pathname = File.join(xml_dir, subdir + '_2' + name + '.xml')
          if File.exist?(pathname)
            return [pathname, subdir + '_2' + name + '.xml']
          else
            pathname = File.join(xml_dir, 'interface_2wx_2' + subdir + '_2' + name + '.xml')
            if File.exist?(pathname)
              return [pathname, 'interface_2wx_2' + subdir + '_2' + name + '.xml']
            end
          end
        end
        pathname = File.join(xml_dir, name + '.xml')
        if File.exist?(pathname)
          [pathname, name + '.xml']
        else
          pathname = File.join(xml_dir, 'interface_2wx_2' + name + '.xml')
          [pathname, 'interface_2wx_2' + name + '.xml']
        end
      end

      public

      # Parse a list of Doxygen XML files and add the item(s) found there to the
      # ModuleDef object.
      #
      # If a name in the list a wx class name then the Doxygen XML filename is
      # calculated from that name, otherwise it is treated as a filename in the
      # Doxygen XML output folder.
      def parse_doxy_xml(moddef, class_or_filename_list)
        filesparsed = Set.new
        until class_or_filename_list.empty?
          class_or_filename = class_or_filename_list.shift
          attempts = []
          pathname = class_to_doxy_name(class_or_filename, attempts)

          unless File.exist?(pathname)
            pathname = class_to_doxy_name(class_or_filename, attempts, 'struct')
            unless File.exist?(pathname)
                pathname, _ = include_to_doxy_name(class_or_filename)
                attempts << pathname
                unless File.exist?(pathname)
                  pathname = File.join(xml_dir, class_or_filename)
                  attempts << pathname
                  unless File.exist?(pathname)
                      msg = "Unable to find xml file for ITEM: %s" % class_or_filename
                      puts(msg)
                      puts("Tried: %s" % (attempts.join("\n       ")))
                      raise DoxyXMLError.new(msg)
                  end
                end
            end
          end

          STDERR.puts("Extractor: Loading %s..." % pathname) if verbose
          filesparsed.add(pathname)

          root = File.open(pathname) {|f| Nokogiri::XML(f) }.root
          root.elements.each do |element|
            # extract and add top-level elements from the XML document
            item = moddef.add_element(element)

            # Also automatically parse the XML for the include file to get related
            # typedefs, functions, enums, etc.
            # Make sure though, that for interface files we only parse the one
            # that belongs to this class. Otherwise, enums, etc. will be defined
            # in multiple places.

            # in case of a class name starting with 'wx' prefix remove the prefix
            xmlname = if /\Awx[A-Z]/ =~ class_or_filename
                        class_or_filename[2..class_or_filename.size]
                      else
                        class_or_filename
                      end
            # lowercase the rest
            xmlname = xmlname.downcase

            if item.respond_to?(:includes)
              item.includes.each do |inc|
                pathname, name = include_to_doxy_name(inc)
                STDERR.puts "Extractor: checking include #{inc} as #{name}:#{pathname} for #{xmlname}" if trace
                class_or_filename_list << name if File.exist?(pathname) &&
                                                  !filesparsed.include?(pathname) &&
                                                  (!name.index('interface') || name.gsub('_2', '').index(xmlname)) &&
                                                  !class_or_filename_list.index(name)
              end
            end
          end

          filesparsed.clear
        end

        moddef.parse_completed
      end

      def xml_dir
        Config.instance.wx_xml_path
      end

      def verbose
        Director.verbose?
      end

      def trace
        Director.trace?
      end

      def extracting_msg(kind, element, name_tag='name')
        STDERR.puts('Extracting %s: %s' % [kind, element.at_xpath("#{name_tag}").text]) if trace
      end

      def skipping_msg(kind, element)
        STDERR.puts('Skipping %s: %s' % [kind, element.at_xpath('name').text]) if trace
      end

      def extract_module(pkg, mod, name, items, gendoc: false)
        moddef = ModuleDef.new(pkg, mod, name, gendoc: gendoc)
        parse_doxy_xml(moddef, items.dup)
        moddef
      end
    end

    # The base class for all element types and provides the common attributes
    # and functions that they all share.
    class BaseDef

      NAME_TAG = 'name'

      def initialize(element = nil)
        @name = '' # name of the item
        @rb_name = nil
        @ignored = false # skip this item
        @docs_ignored = false # skip this item when generating docs
        @brief_doc = nil # either an empty string or text contents of a single para Element
        @detailed_doc = nil # collection of para Elements
        @deprecated = false # is this item deprecated
        @only_for = nil

        # The items list is used by some subclasses to collect items that are
        # part of that item, like methods of a ClassDef, parameters in a
        # MethodDef, etc.
        @items = []

        extract(element) if element
      end

      attr_accessor :name, :rb_name, :ignored, :docs_ignored, :brief_doc, :detailed_doc, :deprecated, :only_for, :items

      def extra_attributes
        @extra_attributes ||= {}
      end

      def update_attributes(**kwargs)
        kwargs.each_pair do |k, v|
          unless self.respond_to?("@#{k}=".to_sym)
            define_singleton_method("#{k}=".to_sym) { |val| extra_attributes[k] = val }
            define_singleton_method("#{k}".to_sym) { extra_attributes[k] }
          end
          self.__send__("#{k}=".to_sym, v)
        end
      end

      def each(&block)
        @items.each(&block)
      end

      def to_s
        "#{self.class.name}: '#{name}'"
      end

      def extract(element)
        # Pull info from the ElementTree element that is pertinent to this
        # class. Should be overridden in derived classes to get what each one
        # needs in addition to the base.
        @name = element.at_xpath("#{self.class::NAME_TAG}").text
        if @name.index('::')
          loc = @name.rindex('::')
          @name = @name.slice(loc + 2, @name.size)
        end
        bd = element.xpath('briefdescription')
        unless bd.empty?
          @brief_doc = bd # Should be just one <para> element
          @detailed_doc = element.xpath('detaileddescription')
          if (el = @detailed_doc.at_xpath('para/onlyfor'))
            @only_for = el.text.strip.split(',').collect { |s| "__#{s.upcase}__" }
            @ignored = @only_for.none? { |s| Config.instance.features_set?(s) }
            @docs_ignored = @ignored
          end
        end
      end

      def check_deprecated
        # Don't iterate all items, just the para items found in detailedDoc,
        # so that classes with a deprecated method don't likewise become deprecated.
        @detailed_doc.xpath('para').each do |para|
          para.elements.each do |item|
            itemid = item['id']
            if itemid and itemid.start_with?('deprecated')
              @deprecated = true
              return
            end
          end
        end
      end

      def clear_deprecated
        # Remove the deprecation notice from the detailedDoc, if any, and reset
        # self.deprecated to False.
        @deprecated = false
        @detailed_doc.each do |para|
          para.elements.each do |item|
            itemid = item['id']
            if itemid and itemid.start_with?('deprecated')
              @detailed_doc.delete(para)
              break
            end
          end
        end
      end

      def ignore(val = true, ignore_doc: nil)
        @ignored = !!val
        @docs_ignored = ignore_doc.nil? ? @ignored : ignore_doc
        self
      end

      def find(name)
        # Locate and return an item within this item that has a matching name.
        # The name string can use a dotted notation to continue the search
        # recursively.
        # The name string can also specify arguments in which case only
        # FunctionDefs are considered
        # Raises ExtractorError if not found.
        argix = name.index('(')
        sep = name.index('::') ? '::' : '.'
        sepix = name.index(sep)
        args = nil
        const = false
        if argix.nil? || (sepix && argix > sepix)
          head, tail = name.split(sep, 2)
        else
          tail = nil
          args = name.slice(argix, name.size)
          head = name.slice(0, argix).tr(' ','')
          const = !!args.index(/\)\s+const/)
          args.sub!(/\)\s+const/, ')') if const
          args.tr!(' ', '')
        end
        _find_items.each do |item|
          if item.name == head && (args.nil? || FunctionDef === item)
            unless tail
              if args
                if (overload = item.find_overload(args, const))
                  return overload
                end
              else
                return item
              end
            else
              return item.find(tail)
            end
          elsif head == '@' && EnumDef === item && item.is_anonymous
            break unless tail # MUST have an enumerator name for anonymous enums
            e = item.find_item(tail)
            return e if e
          end
        end
        raise ExtractorError.new(
                "Unable to find item named '%s' within %s named '%s'" % [head, self.class.name, self.name])
      end

      def find_item(name)
        # Just like find() but does not raise an exception if the item is not found.
        begin
          self.find(name)
        rescue ExtractorError
          nil
        end
      end

      def add_item(item)
        @items << item
        item
      end

      def insert_item(index, item)
        @items.insert(index, item)
        item
      end

      def insert_item_after(after, item)
        idx = @items.index(after)
        if idx
          @items.insert(idx + 1, item)
        else
          @items.append(item)
        end
        item
      end

      def insert_item_before(before, item)
        idx = self.items.index(before)
        if idx
          @items.insert(idx, item)
        else
          @items.insert(0, item)
        end
        item
      end

      def all_items
        # Recursively create a sequence for traversing all items in the
        # collection. An enumerator would be nice but just prebuilding a list will
        # be good enough.
        items = [self]
        @items.each do |item|
          items.concat(item.all_items)
          if item.respond_to?(:overloads)
            item.overloads.each { |o| items.concat(o.all_items) }
          end
          if item.respond_to?(:innerclasses)
            item.innerclasses.each { |c| items.concat(c.all_items) }
          end
        end
        items
      end

      def find_all(name)
        # Search recursively for items that have the given name.
        matches = []
        all_items.each do |item|
          if item.name == name or item.rb_name == name
            matches << item
          end
        end
        matches
      end

      def _find_items
        # If there are more items to be searched than what is in self.items, a
        # subclass can override this to give a different list.
        items
      end
      protected :_find_items

      def inspect
        to_s
      end

      def self.flatten_node(node, rstrip=true)
        # Extract just the text from a node and its children, tossing out any child
        # node tags and attributes.
        # TODO: can we just use ElementTree.tostring for this function?
        return '' unless node
        if node.text?
            return node.text || ''
        end
        text  = node.children.inject('') { |text, n| text << flatten_node(n, rstrip) }
        text = text.rstrip if rstrip
        text
      end

      #---------------------------------------------------------------------------
      # type helpers

      def self.guess_type_int(v)
          return true if v.is_a?(EnumValueDef)

          return true if v.is_a?(DefineDef) && !v.value.index('"')

          type = v.type.sub('const', '')
          type.sub!(' ', '')
          return true  if %w[int long byte size_t wxCoord wxEventType].include?(type)

          return true if type.index('unsigned')

          return false
      end

      def self.guess_type_float(v)
          type = v.type.sub('const', '')
          type.sub!(' ', '')
          return true if %w[float double wxDouble].include?(type)

          return false
      end

      def self.guess_type_str(v)
        return true if v.respond_to?(:value) && v.value.index('"')

        ['wxString', 'wxChar', 'char*', 'char *', 'wchar_t*', 'wchar_t *'].each do |t|
          return true if v.type.index(t)
        end
        return false
      end

    end # class BaseDef

  end # module Extractor

end # module WXRuby3

Dir.glob(File.join(File.dirname(__FILE__), 'extractor', '*.rb')).each do |fn|
  require fn
end
