#--------------------------------------------------------------------
# @file    base.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface generation templates
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

require 'erb'
require 'pathname'
require 'set'

module WXRuby3

  class Generator

    class Spec

      def initialize(ifspec, defmod)
        @ifspec = ifspec
        @defmod = defmod
      end

      def interface_file
        @ifspec.interface_file
      end

      def interface_include
        "#{File.basename(WXRuby3::Config.instance.interface_dir)}/#{@ifspec.module_name}.h"
      end

      def interface_include_file
        "#{WXRuby3::Config.instance.interface_path}/#{@ifspec.module_name}.h"
      end

      def module_name
        @ifspec.module_name
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
        @ifspec.folded_bases.values.any? { |nms| nms.include?(cnm) }
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

      def disowns
        @ifspec.disowns
      end

      def swig_begin_code
        @ifspec.swig_begin_code.join("\n")
      end

      def begin_code
        @ifspec.begin_code.join("\n")
      end

      def swig_runtime_code
        @ifspec.swig_runtime_code.join("\n")
      end

      def runtime_code
        @ifspec.runtime_code.join("\n")
      end

      def swig_header_code
        @ifspec.swig_header_code.join("\n")
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

      def swig_interface_code
        @ifspec.swig_interface_code.join("\n")
      end

      def interface_code
        if @ifspec.interface_code && !@ifspec.interface_code.empty?
          @ifspec.interface_code.join("\n")
        else
          %Q{%include "#{interface_include}"\n}
        end
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
        @defmod.items
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

    def gen_interface_classes(fout, spec)
      spec.def_items.each do |item|
        if Extractor::ClassDef === item && !item.ignored && !item.is_template?
          unless spec.is_folded_base?(item.name)
            gen_interface_class(fout, spec, item)
          end
        end
      end
    end

    def gen_interface_class(fout, spec, classdef)
      fout.puts ''
      basecls = spec.base_class(classdef)
      if basecls
        fout.puts "class #{basecls};"
        fout.puts ''
      end
      is_struct = classdef.kind == 'struct'
      fout.puts "#{classdef.kind} #{spec.class_name(classdef)}#{basecls ? ' : public '+basecls : ''}"
      fout.puts '{'

      unless is_struct
        abstract_class = spec.is_abstract?(classdef)
        if abstract_class
          fout.puts 'private:'
          fout.puts "  #{spec.class_name(classdef)}();"
        end

        fout.puts 'public:'
      end

      methods = []
      gen_interface_class_members(fout, spec, classdef.name, classdef, methods, abstract_class)

      spec.folded_bases(classdef.name).each do |basename|
        gen_interface_class_members(fout, spec, classdef.name, spec.def_item(basename), methods)
      end

      spec.member_extensions(classdef.name).each do |extdecl|
        fout.puts '  // custom wxRuby3 extension'
        fout.puts "  #{extdecl};"
      end

      fout.puts '};'
    end

    def gen_interface_class_members(fout, spec, class_name, classdef, methods, abstract=false)
      # generate any inner classes
      classdef.innerclasses.each do |inner|
        if inner.protection == 'public' && !inner.ignored && !inner.deprecated
          gen_interface_class(fout, spec, inner)
        end
      end
      # generate other members
      classdef.items.each do |member|
        case member
        when Extractor::MethodDef
          if member.is_ctor
            if !abstract && member.protection == 'public' && member.name == class_name
              if !member.ignored && !member.deprecated
                if member.only_for
                  if ::Array === member.only_for
                    fout.puts "#if #{member.only_for.collect { |s| "defined(__#{s.upcase}__)" }.join(' || ')}"
                  else
                    fout.puts "#ifdef #{member.only_for}"
                  end
                end
                fout.puts "  #{spec.class_name(classdef)}#{member.args_string};" if !member.ignored && !member.deprecated
                fout.puts "#endif" if member.only_for
              end
              member.overloads.each do |ovl|
                if ovl.protection == 'public' && !ovl.ignored && !ovl.deprecated
                  if ovl.only_for
                    if ::Array === ovl.only_for
                      fout.puts "#if #{ovl.only_for.collect { |s| "defined(__#{s.upcase}__)" }.join(' || ')}"
                    else
                      fout.puts "#ifdef #{ovl.only_for}"
                    end
                  end
                  fout.puts "  #{spec.class_name(classdef)}#{ovl.args_string};"
                  fout.puts "#endif" if ovl.only_for
                end
              end
            end
          elsif member.is_dtor
            fout.puts "  #{member.is_virtual ? 'virtual ' : ''}~#{spec.class_name(classdef)}#{member.args_string};" if member.name == "~#{class_name}"
          elsif member.protection == 'public'
            gen_interface_class_method(fout, member, methods) if !member.ignored && !member.deprecated && !member.is_template?
            member.overloads.each do |ovl|
              if ovl.protection == 'public' && !ovl.ignored && !ovl.deprecated && !member.is_template?
                gen_interface_class_method(fout, ovl, methods)
              end
            end
          end
        when Extractor::EnumDef
          if member.protection == 'public' && !member.ignored && !member.deprecated
            if member.only_for
              if ::Array === member.only_for
                fout.puts "#if #{member.only_for.collect { |s| "defined(__#{s.upcase}__)" }.join(' || ')}"
              else
                fout.puts "#ifdef #{member.only_for}"
              end
            end
            fout.puts "  // from #{classdef.name}::#{member.name}"
            fout.puts "  enum #{member.name.start_with?('@') ? '' : member.name} {"
            fout.puts member.items.collect { |e| "    #{e.name}" }.join(",\n")
            fout.puts "  };"
            fout.puts "#endif" if member.only_for
          end
        when Extractor::MemberVarDef
          if member.protection == 'public' && !member.ignored && !member.deprecated
            if member.only_for
              if ::Array === member.only_for
                fout.puts "#if #{member.only_for.collect { |s| "defined(__#{s.upcase}__)" }.join(' || ')}"
              else
                fout.puts "#ifdef #{member.only_for}"
              end
            end
            fout.puts "  // from #{member.definition}"
            fout.puts "  #{member.is_static ? 'static ' : ''}#{member.type} #{member.name};"
            fout.puts "#endif" if member.only_for
          end
        end
      end
    end

    def gen_interface_class_method(fout, methoddef, methods)
        unless methoddef.is_pure_virtual ||
                # virtual overrides
                (methoddef.is_virtual && methods.any? { |m| m.signature == methoddef.signature }) ||
                # non-virtual shadowed overloads
                (!methoddef.is_virtual && methods.any? { |m| m.name == methoddef.name && m.class_name != methoddef.class_name })
          if methoddef.only_for
            if ::Array === methoddef.only_for
              fout.puts "#if #{methoddef.only_for.collect { |s| "defined(__#{s.upcase}__)" }.join(' || ')}"
            else
              fout.puts "#ifdef #{methoddef.only_for}"
            end
          end
          fout.puts "  // from #{methoddef.definition}"
          mdecl = methoddef.is_static ? 'static ' : ''
          mdecl << 'virtual ' if methoddef.is_virtual
          fout.puts "  #{mdecl}#{methoddef.type} #{methoddef.name}#{methoddef.args_string};"
          fout.puts "#endif" if methoddef.only_for
          methods << methoddef
        end
    end

    def gen_typedefs(fout, spec)
      typedefs = spec.def_items.select {|item| Extractor::TypedefDef === item && !item.ignored }
      typedefs.each do |item|
        if item.only_for
          if ::Array === item.only_for
            fout << "\n#if #{item.only_for.collect { |s| "defined(__#{s.upcase}__)" }.join(' || ')}"
          else
            fout << "\n#ifdef #{item.only_for}"
          end
        end
        fout << "\n#{item.definition};"
        fout << "\n#endif" if item.only_for
      end
      fout.puts '' unless typedefs.empty?
    end

    def gen_variables(fout, spec)
      vars = spec.def_items.select {|item| Extractor::GlobalVarDef === item && !item.ignored }
      vars.each do |item|
        if item.only_for
          if ::Array === item.only_for
            fout << "\n#if #{item.only_for.collect { |s| "defined(__#{s.upcase}__)" }.join(' || ')}"
          else
            fout << "\n#ifdef #{item.only_for}"
          end
        end
        fout << "\n%constant #{item.definition}#{" #{item.value}".rstrip};"
        fout << "\n#endif" if item.only_for
      end
      fout.puts '' unless vars.empty?
    end

    def gen_enums(fout, spec)
      fout << spec.def_items.inject('') do |code, item|
        if Extractor::EnumDef === item && !item.ignored
          code << "\n// from enum #{item.name || ''}\n"
          item.items.each do |e|
            unless e.ignored
              if e.only_for
                if ::Array === e.only_for
                  code << "#if #{e.only_for.collect { |s| "defined(__#{s.upcase}__)" }.join(' || ')}\n"
                else
                  code << "#ifdef #{e.only_for}\n"
                end
              end
              code << "%constant int #{e.name} = #{e.name};\n"
              code << "#endif\n" if e.only_for
            end
          end
        end
        code
      end
    end

    def gen_defines(fout, spec)
      defines = spec.def_items.select {|item|
        Extractor::DefineDef === item && !item.ignored && !item.is_macro? && item.value && !item.value.empty?
      }
      defines.each do |item|
        if item.only_for
          if ::Array === item.only_for
            fout << "\n#if #{item.only_for.collect { |s| "defined(__#{s.upcase}__)" }.join(' || ')}"
          else
            fout << "\n#ifdef #{item.only_for}"
          end
        end
        if item.value =~ /\A\d/
          fout << "\n#define #{item.name} #{item.value}"
        elsif item.value.start_with?('"')
          fout << "\n%constant char*  #{item.name} = #{item.value};"
        elsif item.value =~ /wxString\((".*")\)/
          fout << "\n%constant char*  #{item.name} = #{$1};"
        else
          fout << "\n%constant int  #{item.name} = #{item.value};"
        end
        fout << "\n#endif" if item.only_for
      end
      fout.puts '' unless defines.empty?
    end

    def gen_functions(fout, spec)
      functions = spec.def_items.select {|item| Extractor::FunctionDef === item && !item.is_template? }
      functions.each do |item|
        active_overloads = item.all.select { |ovl| !ovl.ignored && !ovl.deprecated }
        active_overloads.each do |ovl|
          if ovl.only_for
            if ::Array === ovl.only_for
              fout << "\n#if #{ovl.only_for.collect { |s| "defined(__#{s.upcase}__)" }.join(' || ')}"
            else
              fout << "\n#ifdef #{ovl.only_for}"
            end
          end
          fout << "\n#{ovl.type} #{ovl.name}#{ovl.args_string};"
          fout << "\n#endif" if ovl.only_for
        end
      end
      fout.puts '' unless functions.empty?
    end

  end # class Generator

end # module WXRuby3
