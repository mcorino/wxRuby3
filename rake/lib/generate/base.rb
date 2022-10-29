#--------------------------------------------------------------------
# @file    base.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface generation templates
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

require 'pathname'
require 'set'

require_relative '../util/string'

module WXRuby3

  class Generator

    include Util::StringUtil

    class Spec

      include Util::StringUtil

      def initialize(ifspec, defmod)
        @ifspec = ifspec
        @defmod = defmod
      end

      def post_processors
        @ifspec.post_processors
      end

      def interface_file
        @ifspec.interface_file
      end

      def interface_include
        @ifspec.interface_include
      end

      def interface_include_file
        @ifspec.interface_include_file
      end

      def interface_ext_file
        File.join(@ifspec.package.ruby_classes_path, 'ext', underscore(@ifspec.name)+'.rb')
      end

      def module_name
        @ifspec.module_name
      end

      def name
        @ifspec.name
      end

      def package
        @ifspec.package
      end

      def template_as_class?(tpl)
        @ifspec.template_as_class?(tpl)
      end

      def class_name(classdef_or_name)
        class_def = (Extractor::ClassDef === classdef_or_name ?
                          classdef_or_name : @defmod.find(classdef_or_name))
        @ifspec.class_name(class_def.name)
      end

      def get_base_class(cls, hierarchy, foldedbases, ignoredbases)
        hierarchy = hierarchy.select { |basenm, _| !ignoredbases.include?(basenm) }
        raise "Cannot determin base class for #{cls} from multiple inheritance hierarchy : #{hierarchy}" if hierarchy.size>1
        return nil if hierarchy.empty?
        basenm, bases = hierarchy.first
        return basenm unless foldedbases.include?(basenm)
        get_base_class(basenm, bases, folded_bases(basenm), ignored_bases(basenm))
      end
      private :get_base_class

      def base_class(classdef_or_name)
        class_def = (Extractor::ClassDef === classdef_or_name ?
                          classdef_or_name : @defmod.find(classdef_or_name))
        @ifspec.base_override(class_def.name) ||
              get_base_class(class_def.name, class_def.hierarchy, folded_bases(class_def.name), ignored_bases(class_def.name))
      end

      def get_base_list(hierarchy, foldedbases, ignoredbases, list = ::Set.new)
        hierarchy = hierarchy.select { |basenm, _| !ignoredbases.include?(basenm) }
        hierarchy.each do |basenm, bases|
          list << basenm unless foldedbases.include?(basenm)
          get_base_list(bases, folded_bases(basenm), ignored_bases(basenm), list)
        end
        list
      end

      def base_list(classdef_or_name)
        class_def = (Extractor::ClassDef === classdef_or_name ?
                          classdef_or_name : @defmod.find(classdef_or_name))
        get_base_list(class_def.hierarchy, folded_bases(class_def.name), ignored_bases(class_def.name)).to_a
      end

      def is_folded_base?(cnm)
        @ifspec.is_folded_base?(cnm)
      end

      def folded_bases(cnm)
        @ifspec.folded_bases[cnm] || []
      end

      def ignored_bases(cnm)
        (@ifspec.ignored_bases[cnm] || []) + Director::Spec::IGNORED_BASES
      end

      def member_extensions(cnm)
        @ifspec.member_extensions(cnm)
      end

      def is_abstract?(classdef_or_name)
        class_def = (Extractor::ClassDef === classdef_or_name ?
                          classdef_or_name : @defmod.find(classdef_or_name))
        @ifspec.abstract?(class_def.name) || (class_def.abstract && !@ifspec.concrete?(class_def.name))
      end

      def has_virtuals?(classdef_or_name)
        class_def = (Extractor::ClassDef === classdef_or_name ?
                       classdef_or_name : @defmod.find(classdef_or_name))
        return class_def.all_methods.any? { |m| m.is_virtual }
      end

      def gc_type(classdef)
        unless @ifspec.gc_type(classdef.name)
          if classdef
            return :GC_MANAGE_AS_EVENT if classdef.is_derived_from?('wxEvent') || classdef.name == 'wxEvent'
            return :GC_MANAGE_AS_FRAME if classdef.is_derived_from?('wxFrame') || classdef.name == 'wxFrame'
            return :GC_MANAGE_AS_DIALOG if classdef.is_derived_from?('wxDialog') || classdef.name == 'wxDialog'
            return :GC_MANAGE_AS_WINDOW if classdef.is_derived_from?('wxWindow') || classdef.name == 'wxWindow'
            return :GC_MANAGE_AS_SIZER if classdef.is_derived_from?('wxSizer') || classdef.name == 'wxSizer'
            return :GC_MANAGE_AS_OBJECT if classdef.is_derived_from?('wxObject') || classdef.name == 'wxObject'
            return :GC_MANAGE_AS_TEMP
          end
        end
        @ifspec.gc_type(classdef.name) || :GC_NEVER
      end

      def includes
        @ifspec.includes
      end

      def disabled_proxies
        @ifspec.disabled_proxies
      end

      def no_proxies
        @ifspec.no_proxies
      end

      def forced_proxy?(cls)
        @ifspec.forced_proxy?(cls)
      end

      def has_proxy?(class_def)
        !disabled_proxies &&
          (class_def.ignored || class_def.is_template? || has_virtuals?(class_def) || forced_proxy?(class_def.name)) &&
          !no_proxies.include?(class_name(class_def))
      end

      def disowns
        @ifspec.disowns
      end

      def swig_code
        @ifspec.swig_code.join("\n")
      end

      def begin_code
        @ifspec.begin_code.join("\n")
      end

      def runtime_code
        @ifspec.runtime_code.join("\n")
      end

      def header_code
        @ifspec.header_code.join("\n")
      end

      def wrapper_code
        @ifspec.wrapper_code.join("\n")
      end

      def init_code
        @ifspec.init_code.join("\n")
      end

      def interface_code
        if @ifspec.interface_code && !@ifspec.interface_code.empty?
          @ifspec.interface_code.join("\n")
        else
          %Q{%include "#{interface_include}"\n}
        end
      end

      def has_interface_include?
        @ifspec.has_interface_include?
      end

      def extend_code(cnm)
        (@ifspec.extend_code[cnm] || []).join("\n")
      end

      def swig_imports
        @ifspec.swig_imports
      end

      def swig_includes
        @ifspec.swig_includes
      end

      def renames
        @ifspec.renames
      end

      def def_items
        @defmod ? @defmod.items : []
      end

      def def_item(name)
        @defmod.find_item(name)
      end

      def def_classes
        @defmod.classes
      end

      def no_gen?(section)
        @ifspec.nogen_sections.include?(section)
      end

    end

    def run(spec)
    end

  end # class Generator

end # module WXRuby3
