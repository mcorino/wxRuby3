###
# wxRuby3 wxWidgets interface generation templates
# Copyright (c) M.J.N. Corino, The Netherlands
###

require 'set'

require_relative './base'
require_relative './analyzer'

module WXRuby3

  class DocGenerator < Generator

    class << self

      private

      def get_constants_db
        script = <<~__SCRIPT
          require 'json'
          WX_GLOBAL_CONSTANTS=false
          require 'wx'
          def handle_module(mod, table)
            mod.constants.each do |c|
              a_const = mod.const_get(c)
              if (::Module === a_const || ::Class === a_const) && a_const.name.start_with?('Wx::')  # Wx:: Package submodule or Class (possibly Enum)
                handle_module(a_const, table[c.to_s] = {})
              elsif Wx::Enum === a_const
                table[c.to_s] = { type: a_const.class.name.split('::').last, value: "\#{a_const.class}.new(\#{a_const.to_i})" } 
              elsif !(::Hash === a_const || ::Array === a_const) 
                table[c.to_s] = { type: a_const.class.name.split('::').last, value: a_const } unless c == :THE_APP
              end
            end
          end
          Wx::App.run do 
            table = { 'Wx' => {}}
            handle_module(Wx, table['Wx'])
            STDOUT.puts JSON.dump(table)
          end
        __SCRIPT
        STDERR.puts "* executing constants collection script:\n#{script}" if Director.trace?
        begin
          tmpfile = Tempfile.new('script')
          ftmp_name = tmpfile.path.dup
          tmpfile << script
          tmpfile.close(false)
          result = if Director.trace?
                     Config.instance.run(ftmp_name, capture: :out, verbose: false)
                   else
                     Config.instance.run(ftmp_name, capture: :no_err, verbose: false)
                   end
          STDERR.puts "* got constants collection output:\n#{result}" if Director.trace?
          begin
            db = JSON.load(result)
          rescue Exception
            File.open('constants_raw.json', "w") { |f| f << result } if Director.verbose?
            ::Kernel.raise RuntimeError, "Exception loading constants collection result: #{$!.message.slice(0, 512)}", cause: nil
          end
          File.open('constants.json', "w") { |f| f << JSON.pretty_generate(db) } if Director.verbose?
          return db
        ensure
          File.unlink(ftmp_name)
        end
      end

      def get_constants_xref_db(const_tbl = nil, mods = [])
        xref_tbl = {}
        (const_tbl || constants_db).each_pair do |constnm, constspec|
          unless constspec.has_key?('type')
            xref_tbl[constnm] = { 'mod' => mods.join('::'), 'table' => constspec }
            xref_tbl.merge!(get_constants_xref_db(constspec, mods + [constnm]))
          else
            xref_tbl[constnm] = constspec.merge({'mod' => mods.join('::') })
          end
        end
        File.open('constants_xrefs.json', "w") { |f| f << JSON.pretty_generate(xref_tbl) } if Director.verbose?
        xref_tbl
      end

      public

      def constants_db
        @constants_db ||= get_constants_db
      end

      def constants_xref_db
        @constants_xref_db ||= get_constants_xref_db
      end

    end

    class XMLTransformer

      include DirectorSpecsHelper

      private

      def event_section(f = true)
        @event_section = !!f
      end

      def event_section?
        !!@event_section
      end

      def event_list(f = true)
        @event_list = !!f
      end

      def event_list?
        !!@event_list
      end

      def no_ref(&block)
        was_no_ref = @no_ref
        @no_ref = true
        begin
          return block.call
        ensure
          @no_ref = was_no_ref
        end
      end

      def no_ref?
        !!@no_ref
      end

      def no_idents(&block)
        was_no_idents = @no_idents
        @no_idents = true
        begin
          return block.call
        ensure
          @no_idents = was_no_idents
        end
      end

      def no_idents?
        !!@no_idents
      end

      def _ident_to_ref(idstr)
        idstr.sub(/(.*)(\(.*\))?/) { |_| "{#{$1}}#{$2}" }
      end

      def text_to_doc(node)
        text = node.text
        # handle left-over doxygen tags
        text.gsub!(/@(end)?code/, '')
        text.gsub!('@subsection', '==')
        text.gsub!('@remarks', '')
        text.gsub!(/@see.*\n/, '')
        text.gsub!('@ref', '')
        unless no_ref?
          # auto create references for any ids explicitly declared such
          text.gsub!(/\W?(wx\w+(::\w+)?(\(.*\))?)/) do |s|
            if $1 == 'wxWidgets'
              s
            else
              if s==$1
                doc_id, known_id = _ident_str_to_doc($1)
                known_id ? _ident_to_ref(doc_id) : doc_id
              else
                doc_id, known_id = _ident_str_to_doc($1)
                "#{s[0]}#{known_id ? _ident_to_ref(doc_id) : doc_id}"
              end
            end
          end
        end
        if event_section?
          case text
          when /Event macros for events emitted by this class:/
            event_list(true)
            'Event handler methods for events emitted by this class:'
          when /Event macros:/
            event_list(true)
            'Event handler methods:'
          else
            text
          end
        else
          text
        end
      end

      def computeroutput_to_doc(node)
        if event_section?
          node_to_doc(node)
        elsif /\A[\w:\.]+\Z/ =~ node.text # only a single word/identifier?
          node_to_doc(node)
        else
          no_ref do
            "<code>#{node_to_doc(node)}</code>"
          end
        end
      end

      def bold_to_doc(node)
        "<b>#{node_to_doc(node)}</b>"
      end

      def sp_to_doc(node)
        " #{node_to_doc(node)}"
      end

      def nonbreakablespace_to_doc(node)
        sp_to_doc(node)
      end

      def linebreak_to_doc(node)
        "#{node_to_doc(node)}\n"
      end

      def programlisting_to_doc(node)
        no_idents do
          "\n\n  #{node_to_doc(node).split("\n").join("\n  ")}\n"
        end
      end

      def simplesect_to_doc(node)
        case node['kind']
        when 'since' # get rid of 'Since' notes
          ''
        when 'see'
          no_ref do
            @see_list.concat node_to_doc(node).split(',')
          end
          ''
        else
          node_to_doc(node)
        end
      end

      def _arglist_to_doc(args)
        args.split(',').collect do |a|
          a = a.gsub(/const\s+/, '')
          a.tr!('*&[]', '')
          a.split(' ').last
        end.join(',').strip
      end
      private :_arglist_to_doc

      def _is_method?(itmname, clsnm=nil)
        spec = clsnm ? Director::Spec.class_index[clsnm] : self
        if spec
          if clsnm
            if clsdef = spec.def_item(clsnm)
              if itmdef = clsdef.find_item(itmname)
                return Extractor::FunctionDef === itmdef
              end
            end
          else
            if itmdef = spec.def_item(itmname)
              return Extractor::FunctionDef === itmdef
            end
          end
        end
        false
      end
      private :_is_method?

      def _is_static_method?(clsnm, mtdname)
        if clsspec = Director::Spec.class_index[clsnm]
          if clsdef = clsspec.def_item(clsnm)
            if mtdef = clsdef.find_item(mtdname)
              return Extractor::MethodDef === mtdef && mtdef.is_static
            end
          end
        end
        false
      end
      private :_is_static_method?

      def _ident_str_to_doc(s, ref_scope = nil)
        return s if no_idents?
        nmlist = s.split('::')
        nm_str = nmlist.shift.to_s
        constnm = rb_wx_name(nm_str)
        if nmlist.empty?  # unscoped id?
          if /(\w+)\s*\(([^\)]*)\)/ =~ nm_str   # method with arglist?
            fn = $1
            args = _arglist_to_doc($2)
            mtdsig = args.empty? ? "#{rb_method_name(fn)}" : "#{rb_method_name(fn)}(#{args})"
            if ref_scope
              sep = _is_static_method?(ref_scope, fn) ? '.' : '#'
              constnm = rb_wx_name(ref_scope)
              if DocGenerator.constants_xref_db.has_key?(constnm)
                ["#{DocGenerator.constants_xref_db[constnm]['mod']}::#{constnm}#{sep}#{mtdsig}", true]
              else
                "Wx::#{constnm}#{sep}#{mtdsig}"
              end
            else
              [mtdsig, true]
            end
          else # constant or method name only
            if DocGenerator.constants_xref_db.has_key?(constnm)
              ["#{DocGenerator.constants_xref_db[constnm]['mod']}::#{constnm}", true]
            elsif DocGenerator.constants_xref_db.has_key?(rb_constant_name(nm_str))
              ["Wx::#{rb_constant_name(nm_str)}", true]
            elsif DocGenerator.constants_xref_db.has_key?(rb_constant_name(nm_str, false))
              ["Wx::#{rb_constant_name(nm_str, false)}", true]
            elsif !_is_method?(nm_str, ref_scope)
              ["Wx::#{constnm}", true]
            else
              mtdnm = rb_method_name(nm_str)
              if ref_scope
                sep = _is_static_method?(ref_scope, nm_str) ? '.' : '#'
                constnm = rb_wx_name(ref_scope)
                if DocGenerator.constants_xref_db.has_key?(constnm)
                  ["#{DocGenerator.constants_xref_db[constnm]['mod']}::#{constnm}#{sep}#{mtdnm}", true]
                else
                  "Wx::#{constnm}#{sep}#{mtdnm}"
                end
              else
                [mtdnm, true]
              end
            end
          end
        else # scoped id
          itmnm = nmlist.shift.to_s
          mtd = nil
          args =  nil
          known = true
          if /(\w+)\s*\(([^\)]*)\)/ =~ itmnm
            mtd = $1
            args = _arglist_to_doc($2)
          end
          if DocGenerator.constants_xref_db.has_key?(constnm)
            constnm = "#{DocGenerator.constants_xref_db[constnm]['mod']}::#{constnm}"
          elsif DocGenerator.constants_xref_db.has_key?(rb_constant_name(nm_str))
            cnm = rb_constant_name(nm_str)
            constnm = "#{DocGenerator.constants_xref_db[cnm]['mod']}::#{cnm}"
          elsif DocGenerator.constants_xref_db.has_key?(rb_constant_name(nm_str, false))
            cnm = rb_constant_name(nm_str, false)
            constnm = "#{DocGenerator.constants_xref_db[cnm]['mod']}::#{cnm}"
          elsif nm_str.start_with?('wx')
            known = false
            constnm = "Wx::#{constnm}"
          end
          if mtd.nil?
            if DocGenerator.constants_xref_db.has_key?(rb_wx_name(itmnm)) || !_is_method?(itmnm, nm_str)
              ["#{constnm}::#{rb_wx_name(itmnm)}", known]
            else
              sep = _is_static_method?(nm_str, itmnm) ? '.' : '#'
              ["#{constnm}#{sep}#{rb_method_name(itmnm)}", known]
            end
          elsif nm_str == mtd # ctor?
            [args.empty? ? "#{constnm}\#initialize" : "#{constnm}\#initialize(#{args})", known]
          else
            sep = _is_static_method?(nm_str, mtd) ? '.' : '#'
            [args.empty? ? "#{constnm}#{sep}#{rb_method_name(mtd)}" : "#{constnm}#{sep}#{rb_method_name(mtd)}(#{args})", known]
          end
        end
      end
      private :_ident_str_to_doc

      # transform all cross references
      def ref_to_doc(node)
        return node.text if no_idents?
        if @classdef
          ref = @classdef.crossref_table[node['refid']]
        end
        ref ||= {}
        return node.text if /\s/ =~ node.text # no crossref transforming if text contains whitespace; return plain text
        if no_ref?
          doc_id, _ = _ident_str_to_doc(node.text, ref[:scope])
          doc_id
        else
          doc_id, id_known = _ident_str_to_doc(node.text, ref[:scope])
          id_known ? _ident_to_ref(doc_id) : doc_id
        end
      end

      # transform all titles
      def title_to_doc(node)
        "== #{node.text}\n"
      end

      def heading_to_doc(node)
        lvl = 1+(node['level'] || '1').to_i
        txt = node_to_doc(node)
        event_section(/Events emitted by this class|Events using this class/i =~ txt)
        "#{'=' * lvl} #{txt}"
      end

      # transform all itemizedlist
      def itemizedlist_to_doc(node)
        doc = node_to_doc(node)
        if event_list?
          # event emitter block ended
          event_list(false)
          event_section(false)
        end
        doc
      end

      # transform all listitem
      def listitem_to_doc(node)
        itm_text = node_to_doc(node)
        # fix possible unwanted leading spaces resulting in verbatim blocks
        itm_text = itm_text.split("\n").collect {|s|s.lstrip}.join("\n") if itm_text.index("\n")
        "- #{itm_text}"
      end

      def node_to_doc(xmlnode)
        xmlnode.children.inject('') do |docstr, node|
          docstr << self.__send__("#{node.name}_to_doc", node)
        end
      end

      def get_event_override(evt)
        if ifspec.event_overrides.has_key?(@classdef.name)
          return ifspec.event_overrides[@classdef.name][evt] || ifspec.event_overrides[@classdef.name][evt.upcase]
        end
        nil
      end
      private :get_event_override

      def para_to_doc(node)
        para = node_to_doc(node)
        # loose specific notes paragraphs
        case para
        when /\A(\<b\>)?wxPerl Note:/,  # wxPerl note
             /\A\s*Library:/,           # Library note
             /\A\s*Include\s+file:/     # Include file note
          ''
        else
          para.sub!(/Include\s+file:\s+\#include\s+\<[^>]+\>\s*\Z/, '')
          if event_section?
            case para
            when /The following event handler macros redirect.*(\{.*})/
              event_ref = $1
              "The following event-handler methods redirect the events to member method or handler blocks for #{event_ref} events."
            when /\AEVT_[A-Z]+/
              if event_list? && /\A(EVT_[_A-Z]+)\((.*,)\s+\w+\):(.*)/ =~ para
                evthnd_name = $1.downcase
                if override_spec = get_event_override(evthnd_name)
                  evthnd_name, evt_type, evt_arity, evt_klass = override_spec
                  idarg = case evt_arity
                          when 0
                            ''
                          when 1
                            'id, '
                          when 2
                            'first_id, last_id, '
                          end
                  arglist = "#{idarg}meth = nil, &block"
                else
                  arglist = "#{$2} meth = nil, &block"
                end
                docstr = $3.lstrip
                package.event_docs[evthnd_name] = [arglist, docstr.dup] # register for eventlist doc gen
                "{Wx::EvtHandler\##{evthnd_name}}(#{arglist}): #{docstr}"
              elsif event_list? && /\A(EVT_[_A-Z]+)(\*)?\(\w+\):(.*)/ =~ para
                wildcard = ($2 == '*')
                evthnd_name = $1.downcase
                arglist = "meth = nil, &block"
                docstr = $3.lstrip
                package.event_docs[wildcard ? /\A#{evthnd_name}/ : evthnd_name] = [arglist, docstr.dup] # register for eventlist doc gen
                if wildcard
                  "{Wx::EvtHandler}#{evthnd_name}*(#{arglist}): #{docstr}"
                else
                  "{Wx::EvtHandler\##{evthnd_name}}(#{arglist}): #{docstr}"
                end
              else
                para
              end
            else
              para
            end
          else
            para
          end
        end
      end

      def method_missing(mtd, *args, &block)
        if /\A\w+_to_doc\Z/ =~ mtd.to_s && args.size==1
          node_to_doc(*args)
        else
          super
        end
      end

      public

      def initialize(director)
        @director = director
        @classdef = nil
        @see_list = []
      end

      attr_reader :director

      def for_class(clsdef, &block)
        prevcls = @classdef
        @classdef = clsdef
        begin
          block.call
        ensure
          @classdef = prevcls
        end
      end

      def to_doc(xmlnode_or_set)
        return '' unless xmlnode_or_set
        @see_list.clear
        doc = if Nokogiri::XML::NodeSet === xmlnode_or_set
                xmlnode_or_set.inject('') { |s, n| s << node_to_doc(n) }
              else
                node_to_doc(xmlnode_or_set)
              end
        event_section(false)
        doc.strip!
        # reduce triple(or more) newlines to max 2
        doc << "\n" # always end with a NL without following whitespace
        doc.gsub!(/\n *\n *\n+/, "\n\n")
        # add crossref tags
        @see_list.each { |s| doc << "@see #{s}\n" }
        doc
      end

      def constants_db
        DocGenerator.constants_db
      end

      def constants_xref_db
        DocGenerator.constants_xref_db
      end

    end

    def run
      # run an analysis comparing inherited generated methods with this class's own generated methods
      InterfaceAnalyzer.check_interface_methods(@director, doc_gen: true)

      @xml_trans = DocGenerator::XMLTransformer.new(@director)
      Stream.transaction do
        fdoc = CodeStream.new(File.join(package.ruby_doc_path, underscore(name)+'.rb'))
        fdoc << <<~__HEREDOC
          # :stopdoc:
          # This file is automatically generated by the WXRuby3 documentation 
          # generator. Do not alter this file.
          # :startdoc:
        __HEREDOC
        # at least 2 newlines to make Yard skip/forget the header comment
        fdoc.puts
        fdoc.puts
        fdoc.puts "module #{package.fullname}"
        fdoc.puts
        fdoc.indent do
          gen_constants_doc(fdoc)
          gen_functions_doc(fdoc) unless no_gen?(:functions)
          gen_class_doc(fdoc) unless no_gen?(:classes)
        end
        fdoc.puts
        fdoc.puts 'end'
      end
    end

    protected

    def get_constant_doc(const)
      @xml_trans.to_doc(const.brief_doc)
    end

    def gen_constant_value(val)
      if ::String === val && /\A(#<(.*)>|[\w:]+\.new\(.*\))\Z/ =~ val
        if $2
          valstr = $2
          if /\Awx/ =~ valstr
            valstr.sub(/\Awx/, '')
          else
            'nil'
          end
        else
          $1
        end
      else
        val.inspect
      end
    end

    def gen_constant_doc(fdoc, name, spec, doc)
      fdoc.doc.puts doc
      fdoc.puts "#{name} = #{gen_constant_value(spec['value'])}"
      fdoc.puts
    end

    def get_enum_doc(enumdef)
      doc = @xml_trans.to_doc(enumdef.brief_doc)
      doc << "\n" if enumdef.detailed_doc
      doc << @xml_trans.to_doc(enumdef.detailed_doc) if enumdef.detailed_doc
      doc
    end

    def gen_enum_doc(fdoc, enumname, enumdef, enum_table)
      fdoc.doc.puts get_enum_doc(enumdef)
      fdoc.puts "class #{enumname} < Wx::Enum"
      fdoc.puts
      fdoc.indent do
        enumdef.items.each do |e|
          const_name = rb_wx_name(e.name)
          if enum_table.has_key?(const_name)
            gen_constant_doc(fdoc, const_name, enum_table[const_name], get_constant_doc(e))
          end
        end
      end
      fdoc.puts "end # #{enumname}"
      fdoc.puts
    end

    def gen_constants_doc(fdoc)
      xref_table = package.all_modules.reduce(DocGenerator.constants_db) { |db, mod| db[mod] }
      def_items.select {|itm| !itm.docs_ignored }.each do |item|
        case item
        when Extractor::GlobalVarDef
          unless no_gen?(:variables)
            const_name = rb_constant_name(item.name)
            if xref_table.has_key?(const_name)
              gen_constant_doc(fdoc, const_name, xref_table[const_name], get_constant_doc(item))
            end
          end
        when Extractor::EnumDef
          unless no_gen?(:enums)
            if item.is_type
              enum_name = rb_wx_name(item.name)
              if xref_table.has_key?(enum_name)
                gen_enum_doc(fdoc, enum_name, item, xref_table[enum_name] || {})
              end
            else
              item.items.each do |e|
                const_name = rb_constant_name(e.name, false)
                if xref_table.has_key?(const_name)
                  gen_constant_doc(fdoc, const_name, xref_table[const_name], get_constant_doc(e))
                end
              end
            end
          end
        when Extractor::DefineDef
          unless no_gen?(:defines)
            if !item.is_macro? && item.value && !item.value.empty?
              const_name = rb_constant_name(item.name)
              if xref_table.has_key?(const_name)
                gen_constant_doc(fdoc, const_name, xref_table[const_name], get_constant_doc(item))
              end
            end
          end
        end
      end
    end

    def get_function_doc(func)
      func.rb_doc(@xml_trans, type_maps)
    end

    def gen_functions_doc(fdoc)
      def_items.select {|itm| !itm.docs_ignored }.each do |item|
        if Extractor::FunctionDef === item && !item.docs_ignored
          get_method_doc(item).each_pair do |name, docs|
            if docs.size>1 # method with overloads?
              docs.each do |params, ovl_doc|
                fdoc.doc.puts "@overload #{name}(#{params})"
                fdoc.doc.indent { fdoc.doc.puts ovl_doc }
              end
              fdoc.puts "def #{name}(*args) end"
            else
              params, doc = docs.shift
              fdoc.doc.puts doc
              if params.empty?
                fdoc.puts "def #{name}; end"
              else
                fdoc.puts "def #{name}(#{params}) end"
              end
            end
            fdoc.puts
          end
        end
      end
    end

    def get_class_doc(cls)
      doc = @xml_trans.to_doc(cls.brief_doc)
      doc << @xml_trans.to_doc(cls.detailed_doc) if cls.detailed_doc
      doc
    end

    def get_method_doc(mtd)
      mtd.rb_doc(@xml_trans, type_maps)
    end

    def get_method_head(clsdef, mtdef)
      if mtdef.class_name == clsdef.name
        # get method head item
        clsdef.items.find { |m| Extractor::MethodDef === m && m.name == mtdef.name }
      else
        # check folded bases
        base = folded_bases(clsdef.name).find { |bc| bc == mtdef.class_name }
        base = def_classes.find { |c| base == c.name }
        base ? base.items.find { |m| Extractor::MethodDef === m && m.name == mtdef.name } : nil
      end
    end

    def gen_class_doc_members(fdoc, clsdef, cls_members, alias_methods)
      # generate method and member variable documentation
      mtd_done = ::Set.new
      cls_members.each do |cm|
        case cm
        when Extractor::MethodDef
          # overloads are flattened out by the Analyzer keeping only the non-ignored items
          # but for doc gen we need the head item (and only that, so keep track and skip the rest)
          unless cm.is_dtor || mtd_done.include?(cm.name)
            # get method head item
            mtd_head = get_method_head(clsdef, cm)
            get_method_doc(mtd_head).each_pair do |name, docs|
              if docs.size>1 # method with overloads?
                docs.each do |params, ovl_doc|
                  fdoc.doc.puts "@overload #{name}(#{params})"
                  fdoc.doc.indent { fdoc.doc.puts ovl_doc }
                end
                fdoc.puts "def #{name}(*args) end"
              else
                params, doc = docs.shift
                fdoc.doc.puts doc
                if params.empty?
                  fdoc.puts "def #{name}; end"
                else
                  fdoc.puts "def #{name}(#{params}) end"
                end
              end
              # check for SWIG generated aliases
              if alias_methods.has_key?(cm.name)
                fdoc.puts "alias_method :#{alias_methods[cm.name]}, :#{name}"
              else
                # check for aliases that will be available from WxRubyStyleAccessors at runtime
                # and document these as well
                alias_name = case name
                             when /\Aget_(\w+)/
                               $1
                             when /\Aset_(\w+)/
                               if mtd_head.all.any? { |ovl| ovl.parameter_count > 0 && ovl.required_param_count < 2 }
                                 "#{$1}="
                               else
                                 nil
                               end
                             when /\Ais_(\w+)/
                               "#{$1}?"
                             when /\A(has_|can_)/
                               "#{name}?"
                             else
                               nil
                             end
                # only consider alias if no other method matching alias_name exists as WxRubyStyleAccessors
                # aliases rely on method_missing being called
                if alias_name &&
                  !cls_members.any? { |m| Extractor::MethodDef === m && !m.ignored && m.rb_decl_name == alias_name }
                  fdoc.puts "alias_method :#{alias_name}, :#{name}"
                end
              end
              fdoc.puts
            end
            mtd_done << cm.name
          end
        when Extractor::MemberVarDef
          rd_doc, rd_decl, wr_doc, wr_decl = cm.rb_doc(@xml_trans, type_maps)
          rd_doc.each { |s| fdoc.doc.puts s }
          fdoc.puts rd_decl
          if wr_doc
            wr_doc.each { |s| fdoc.doc.puts s }
            fdoc.puts wr_decl
          end
          fdoc.puts
        end
      end
    end

    def gen_class_doc(fdoc)
      const_table = package.all_modules.reduce(DocGenerator.constants_db) { |db, mod| db[mod] }
      def_items.select {|itm| !itm.docs_ignored && Extractor::ClassDef === itm && !is_folded_base?(itm.name) }.each do |item|
        if !item.is_template? || template_as_class?(item.name)
          @xml_trans.for_class(item) do
            intf_class_name = if (item.is_template? && template_as_class?(item.name))
                                template_class_name(item.name)
                              else
                                item.name
                              end
            clsnm = rb_wx_name(intf_class_name)
            xref_table = const_table[clsnm] || {}
            fdoc.doc.puts get_class_doc(item)
            if is_mixin?(item)
              fdoc.doc.puts "\n@note  In wxRuby this is a mixin module instead of a (base) class."
              fdoc.puts "module #{clsnm}"
            else
              basecls = ifspec.classdef_name(base_class(item, doc: true))
              fdoc.puts "class #{clsnm} < #{basecls ? basecls.sub(/\Awx/, '') : '::Object'}"
            end
            fdoc.puts

            # mixin includes
            if included_mixins.has_key?(item.name)
              included_mixins[item.name].each { |mod| fdoc.iputs "include #{mod}" }
              fdoc.puts
            end

            # collect possible aliases
            alias_methods = item.aliases
            folded_bases(item.name).each do |basename|
              alias_methods = def_item(basename).aliases.merge(alias_methods)
            end

            fdoc.indent do
              cls_members = InterfaceAnalyzer.class_interface_members_public(intf_class_name)
              # generate documentation for any enums
              cls_members.each do |member|
                case member
                when Extractor::EnumDef
                  unless member.is_type
                    member.items.each do |e|
                      const_name = rb_constant_name(e.name)
                      if xref_table.has_key?(const_name)
                        gen_constant_doc(fdoc, const_name, xref_table[const_name], get_constant_doc(e))
                      end
                    end
                  else
                    enum_name = rb_wx_name(member.name)
                    if xref_table.has_key?(enum_name)
                      gen_enum_doc(fdoc, enum_name, member, xref_table[enum_name] || {})
                    end
                  end
                end
              end if xref_table
              # generate method and member var documentation
              gen_class_doc_members(fdoc, item, cls_members, alias_methods)

              cls_members = InterfaceAnalyzer.class_interface_members_protected(intf_class_name)
              unless cls_members.empty?
                fdoc.puts
                fdoc.puts 'protected'
                fdoc.puts
                gen_class_doc_members(fdoc, item, cls_members, alias_methods)
              end
            end
            fdoc.puts "end # #{clsnm}"
            fdoc.puts
          end
        end
      end
    end

  end

end
