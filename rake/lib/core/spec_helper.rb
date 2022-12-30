###
# wxRuby3 Director specs helper mixin.
# Copyright (c) M.J.N. Corino, The Netherlands
###

require 'pathname'
require 'set'

require_relative '../util/string'

module WXRuby3

  module DirectorSpecsHelper

    include Util::StringUtil

    def ifspec
      director.spec
    end

    def defmod
      director.defmod
    end

    def post_processors
      ifspec.post_processors
    end

    def interface_file
      ifspec.interface_file
    end

    def interface_include
      ifspec.interface_include
    end

    def interface_include_file
      ifspec.interface_include_file
    end

    def interface_ext_file
      File.join(ifspec.package.ruby_classes_path, 'ext', underscore(ifspec.name)+'.rb')
    end

    def module_name
      ifspec.module_name
    end

    def name
      ifspec.name
    end

    def package
      ifspec.package
    end

    def template_as_class?(tpl)
      ifspec.template_as_class?(tpl)
    end

    def template_class_name(tpl)
      ifspec.template_class_name(tpl)
    end

    def classdef_for_name(name)
      defmod.find(ifspec.classdef_name(name))
    end

    def class_name(classdef_or_name)
      class_def = (Extractor::ClassDef === classdef_or_name ?
                     classdef_or_name : classdef_for_name(classdef_or_name))
      ifspec.class_name(class_def.name)
    end

    def get_base_class(cls, hierarchy, foldedbases)
      raise "Cannot determine base class for #{cls} from multiple inheritance hierarchy : #{hierarchy}" if hierarchy.size>1
      return nil if hierarchy.empty?
      basenm, base = hierarchy.first
      return basenm unless foldedbases.include?(basenm)
      get_base_class(basenm, base.supers, folded_bases(basenm))
    end
    private :get_base_class

    def base_class(classdef_or_name, doc: false)
      class_def = (Extractor::ClassDef === classdef_or_name ?
                     classdef_or_name : classdef_for_name(classdef_or_name))
      if (base = ifspec.inheritance_override(class_def.name, doc: doc))
        base.name
      else
        get_base_class(class_def.name, class_def.hierarchy, folded_bases(class_def.name))
      end
    end

    private def get_base_list(hierarchy, foldedbases, list = ::Set.new)
      hierarchy.each_value do |super_def|
        list << super_def.name unless foldedbases.include?(super_def.name)
        get_base_list(super_def.supers, folded_bases(super_def.name), list)
      end
      list
    end

    def base_list(classdef_or_name)
      class_def = (Extractor::ClassDef === classdef_or_name ?
                     classdef_or_name : classdef_for_name(classdef_or_name))
      base = ifspec.inheritance_override(class_def.name)
      hierarchy = (base && (base.name ? {base.name => base} : {})) || class_def.hierarchy
      get_base_list(hierarchy, folded_bases(class_def.name)).to_a
    end

    private def get_base_module_list(hierarchy, foldedbases, list = ::Set.new)
      hierarchy.each_value do |super_def|
        list << super_def.module unless foldedbases.include?(super_def.name)
        get_base_module_list(super_def.supers, folded_bases(super_def.name), list)
      end
      list
    end

    def base_module_list(classdef_or_name)
      class_def = (Extractor::ClassDef === classdef_or_name ?
                     classdef_or_name : classdef_for_name(classdef_or_name))
      base = ifspec.inheritance_override(class_def.name)
      hierarchy = (base && (base.name ? {base.name => base} : {})) || class_def.hierarchy
      get_base_module_list(hierarchy, folded_bases(class_def.name)).to_a
    end

    def is_folded_base?(cnm)
      ifspec.is_folded_base?(cnm)
    end

    def folded_bases(cnm)
      ifspec.folded_bases[cnm] || []
    end

    def interface_extensions(classdef_or_name, visibility='public')
      class_def = (Extractor::ClassDef === classdef_or_name ?
                     classdef_or_name : classdef_for_name(classdef_or_name))
      ifspec.interface_extensions(class_def.name)[visibility] || []
    end

    def is_abstract?(classdef_or_name)
      class_def = (Extractor::ClassDef === classdef_or_name ?
                     classdef_or_name : classdef_for_name(classdef_or_name))
      ifspec.abstract?(class_def.name) || (class_def.abstract && !ifspec.concrete?(class_def.name))
    end

    def has_virtuals?(classdef_or_name)
      class_def = (Extractor::ClassDef === classdef_or_name ?
                     classdef_or_name : classdef_for_name(classdef_or_name))
      return class_def.all_methods.any? { |m| m.is_virtual }
    end

    def gc_type(classdef)
      unless ifspec.gc_type(classdef.name)
        if classdef
          return :GC_MANAGE_AS_EVENT if classdef.is_derived_from?('wxEvent') || classdef.name == 'wxEvent'
          return :GC_MANAGE_AS_FRAME if classdef.is_derived_from?('wxFrame') || classdef.name == 'wxFrame'
          return :GC_MANAGE_AS_DIALOG if classdef.is_derived_from?('wxDialog') || classdef.name == 'wxDialog'
          return :GC_MANAGE_AS_WINDOW if classdef.is_derived_from?('wxWindow') || classdef.name == 'wxWindow'
          return :GC_MANAGE_AS_SIZER if classdef.is_derived_from?('wxSizer') || classdef.name == 'wxSizer'
          return :GC_MANAGE_AS_REFCOUNTED if classdef.is_derived_from?('wxRefCounter')
          return :GC_MANAGE_AS_OBJECT if classdef.is_derived_from?('wxObject') || classdef.name == 'wxObject'
          return :GC_MANAGE_AS_TEMP
        end
      end
      ifspec.gc_type(classdef.name) || :GC_NEVER
    end

    def includes
      ifspec.includes
    end

    def disabled_proxies
      ifspec.disabled_proxies
    end

    def no_proxies
      ifspec.no_proxies
    end

    def forced_proxy?(cls)
      ifspec.forced_proxy?(cls)
    end

    def has_proxy?(classdef_or_name)
      class_def = (Extractor::ClassDef === classdef_or_name ?
                     classdef_or_name : classdef_for_name(classdef_or_name))
      rc =!disabled_proxies
      rc &&= (class_def.ignored ||
          class_def.is_template? ||
          has_virtuals?(class_def) ||
          forced_proxy?(class_def.name))
      clsnm = class_name(class_def)
      rc &&= !no_proxies.include?(clsnm)
      rc
    end

    def has_method_proxy?(classdef_or_name, methoddef)
      return false unless methoddef.is_virtual
      class_def = (Extractor::ClassDef === classdef_or_name ?
                     classdef_or_name : classdef_for_name(classdef_or_name))
      if has_proxy?(class_def)
        no_proxies.each do |decls|
          decl_clsnm, decl_mtd = decls.split('::')
          # do we have a no_proxy decl for a method in this class?
          if decl_mtd && decl_clsnm == class_name(class_def)
            decl_mtd.tr!("\n", ' ')
            # do we have a full method signature for the no_proxy decl?
            if /\A(\w+)\s*\(([^\)]*)\)\s*(const)?/ =~ decl_mtd
              # does the method name match?
              if $1 == methoddef.name
                arg_list = $2
                is_const = $3 == 'const'
                # remove any default arg values
                arg_list = arg_list.split(',').collect {|argdecl| argdecl.split('=').first.strip }
                # remove any argument names
                arg_list.collect do |argdecl|
                  lst = argdecl.split(' ')
                  argdecl = lst.shift # 'const' or type
                  argdecl << " #{lst.shift}" if argdecl == 'const' # type if 'const'
                  unless lst.empty? # name of [] left?
                    argdecl << lst.shift if lst.first == '*' || lst.first == '&'
                    if /\A([\*\&]?)\w+/ =~ lst.first
                      argdecl << $1 unless $1 == ''
                      lst.shift # loose name
                    end
                    argdecl << lst.join unless lst.empty?
                  end
                  argdecl
                end
                # in case the complete signature maches the proxy is suppressed for this method
                return false if arg_list.join.tr(' ', '') == methoddef.argument_list.tr(' ', '') && is_const == methoddef.is_const
              end
            else
              # in case the method name matches the proxy is suppressed for this method
              return false if decl_mtd == methoddef.name
            end
          end
        end
        return true # method will have proxy
      end
      false # method will not have proxy as there will not be a proxy (director) class
    end

    def disowns
      ifspec.disowns
    end

    def new_objects
      ifspec.new_objects
    end

    def warn_filters
      ifspec.warn_filters
    end

    def swig_code
      ifspec.swig_code.join("\n")
    end

    def begin_code
      ifspec.begin_code.join("\n")
    end

    def runtime_code
      ifspec.runtime_code.join("\n")
    end

    def header_code
      ifspec.header_code.join("\n")
    end

    def wrapper_code
      ifspec.wrapper_code.join("\n")
    end

    def init_code
      ifspec.init_code.join("\n")
    end

    def interface_code
      if ifspec.interface_code && !ifspec.interface_code.empty?
        ifspec.interface_code.join("\n")
      else
        %Q{%include "#{interface_include}"\n}
      end
    end

    def has_interface_include?
      ifspec.has_interface_include?
    end

    def extend_code(cnm)
      (ifspec.extend_code[cnm] || []).join("\n")
    end

    def swig_imports
      ifspec.swig_imports
    end

    def swig_includes
      ifspec.swig_includes
    end

    def renames
      ifspec.renames
    end

    def def_items
      defmod ? defmod.items : []
    end

    def def_item(name)
      defmod.find_item(name)
    end

    def def_classes
      defmod.classes
    end

    def no_gen?(section)
      ifspec.nogen_sections.include?(section)
    end

    def type_maps
      Typemap::Collection::Chain.new(Typemap::STANDARD, Typemap::Collection::Chain.new(director.class.type_maps, ifspec.type_maps).resolve)
    end

    class Simple
      include DirectorSpecsHelper
      def initialize(director)
        @director = director
      end

      attr_reader :director
    end

  end

end
