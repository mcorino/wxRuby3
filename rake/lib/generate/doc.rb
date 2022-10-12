#--------------------------------------------------------------------
# @file    doc.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface generation templates
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

require_relative './base'

module WXRuby3

  class DocGenerator < Generator

    class << self

      private

      def get_constants_db
        script = <<~__SCRIPT
          require 'json'
          require 'wx'
          table = { 'Wx' => {}}
          Wx.constants.each do |c|
            the_const = Wx.const_get(c)
            if the_const.class == ::Module  # Enum submodule
              modname = c.to_s
              mod = Wx.const_get(c) 
              table[modname] = {}
              mod.constants.each do |ec|
                e_const = mod.const_get(ec)
                table[modname][ec.to_s] = { type: e_const.class.name.split('::').last, value: e_const }
              end
            else
              table['Wx'][c.to_s] = { type: the_const.class.name.split('::').last, value: the_const } unless ::Class === the_const
            end
          end
          STDOUT.puts JSON.dump(table)
        __SCRIPT
        begin
          tmpfile = Tempfile.new('script')
          ftmp_name = tmpfile.path.dup
          tmpfile << script
          tmpfile.close(false)
          rubycmd = `which ruby`.chomp
          rubycmd << " -I#{File.join(WXRuby3::Config.wxruby_root, 'lib')} #{ftmp_name}"
          result = `#{rubycmd} 2>/dev/null`
          db = JSON.load(result)
          return db
        ensure
          File.unlink(ftmp_name)
        end
      end

      def get_constants_xref_db
        xref_tbl = {}
        constants_db.each_pair do |modnm, modtbl|
          modtbl.each_pair do |const_name, const_spec|
            xref_tbl[const_name] = const_spec.merge({ 'mod' => modnm })
          end
        end
        xref_tbl
      end

      public

      def xml_doc_to_rb(xml)
        # transform all <itemizedlist>
        doc.gsub!(/\<itemizedlist>(.*)(\<\/itemizedlist>){1,1}/) do |s|
          STDERR.puts s
          STDERR.puts list = $1.dup
          list.gsub(/\<listitem>(.*)(\<\/listitem>){,1}/) { |s1| p s1; '- '+$1 }
        end

        # remove all left-over xml tags
        doc.gsub!(/<[^>]+>/, '')
        doc
      end

      def constants_db
        @constants_db ||= get_constants_db
      end

      def constants_xref_db
        @constants_xref_db ||= get_constants_xref_db
      end

    end

    module XMLTransform

      class << self

        include Util::StringUtil

        private

        def text_to_doc(node)
          node.text
        end

        def bold_to_doc(node)
          "*#{node_to_doc(node)}*"
        end

        def para_to_doc(node)
          node_to_doc(node)
        end

        def _arglist_to_doc(args)
          args.split(',').collect do |a|
            a = a.gsub(/const\s+/, '')
            a.tr!('*&[]', '')
            a.split(' ').last
          end.join(',')
        end

        def _ident_str_to_doc(s)
          nmlist = s.split('::')
          nm_str = nmlist.shift.to_s
          constnm = rb_wx_name(nm_str)
          if nmlist.empty?
            if /(\w+)\s*\(([^\)]*)\)/ =~ nm_str
              fn = $1
              args = _arglist_to_doc($2)
              "{Wx::#{rb_method_name(fn)}(#{args})}"
            else
              if DocGenerator.constants_xref_db.has_key?(constnm)
                "{#{DocGenerator.constants_xref_db[constnm]['mod']}::#{constnm}}"
              else
                "{#{nm_str.start_with?('wx') ? 'Wx::' : ''}#{constnm}}"
              end
            end
          else
            mtd = nmlist.shift.to_s
            args =  nil
            if /(\w+)\s*\(([^\)]*)\)/ =~ mtd
              mtd = $1
              args = _arglist_to_doc($2)
            end
            if nm_str == mtd
              "{#{nm_str.start_with?('wx') ? 'Wx::' : ''}#{constnm}\#initialize(#{args})}"
            else
              "{#{nm_str.start_with?('wx') ? 'Wx::' : ''}#{constnm}\##{rb_method_name(mtd)}#{args}}"
            end
          end
        end

        # transform all cross references
        def ref_to_doc(node)
          _ident_str_to_doc(node.text)
        end

        # transform all titles
        def title_to_doc(node)
          "== #{node.text}\n"
        end

        # transform all itemizedlist
        def itemizedlist_to_doc(node)
          node_to_doc(node)
        end

        # transform all listitem
        def listitem_to_doc(node)
          "- #{node_to_doc(node)}"
        end

        def node_to_doc(xmlnode)
          xmlnode.children.inject('') do |docstr, node|
            docstr << self.__send__("#{node.name}_to_doc", node)
          end
        end

        public

        def method_missing(mtd, *args, &block)
          if /\A\w+_to_doc\Z/ =~ mtd.to_s && args.size==1
            node_to_doc(*args)
          else
            super
          end
        end
      end

      def self.to_doc(xmlnode_or_set)
        return '' unless xmlnode_or_set
        doc = if Nokogiri::XML::NodeSet === xmlnode_or_set
                xmlnode_or_set.inject('') { |s, n| s << node_to_doc(n) }
              else
                node_to_doc(xmlnode_or_set)
              end
        doc.lstrip!
        # reduce triple(or more) newlines to max 2
        doc.gsub!(/\n\n\n+/, "\n\n")
        # autocreate references for any ids explicitly declared such
        doc.gsub!(/\s\*?(wx\w+(::\w+)?(\(.*\))?)\*?[\.:\s]/) do |s|
          if $1 == 'wxWidgets'
            s
          else
            "#{s[0]}#{_ident_str_to_doc($1)}#{s[-1]}"
          end
        end
        doc
      end

    end

    def run(genspec)
      Stream.transaction do
        fdoc = CodeStream.new(File.join(Config.instance.rb_doc_path, underscore(genspec.name)+'.rb'))
        fdoc << <<~__HEREDOC
          # ----------------------------------------------------------------------------
          # This file is automatically generated by the WXRuby3 documentation 
          # generator. Do not alter this file.
          # ----------------------------------------------------------------------------
        __HEREDOC
        # at least 2 newlines to make Yard skip/forget the header comment
        fdoc.puts
        fdoc.puts
        fdoc.puts "module #{genspec.package.sub(/\A[a-z]/) {|s| s.upcase }}"
        fdoc.puts
        fdoc.indent do
          gen_constants_doc(fdoc, genspec)
          gen_class_doc(fdoc, genspec)
        end
        fdoc.puts
        fdoc.puts 'end'
      end
    end

    def gen_constant_value(val)
      if ::String === val && /\A#<(.*)>\Z/ =~ val
        valstr = $1
        if /\Awx/ =~ valstr
          valstr.sub(/\Awx/, '')
        else
          'nil'
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

    def gen_enum_doc(fdoc, enumname, enumdef, enum_table)
      fdoc.doc.puts DocGenerator::XMLTransform.to_doc(enumdef.brief_doc)
      fdoc.doc.puts
      fdoc.doc.puts DocGenerator::XMLTransform.to_doc(enumdef.detailed_doc) if enumdef.detailed_doc
      fdoc.puts "module #{enumname}"
      fdoc.puts
      fdoc.indent do
        enumdef.items.each do |e|
          const_name = rb_wx_name(e.name)
          if enum_table.has_key?(const_name)
            gen_constant_doc(fdoc, const_name, enum_table[const_name], DocGenerator::XMLTransform.to_doc(e.brief_doc))
          end
        end
      end
      fdoc.puts "end # #{enumname}"
      fdoc.puts
    end

    def gen_constants_doc(fdoc, genspec)
      const_table = DocGenerator.constants_db
      wx_consts = const_table['Wx'] || {}
      genspec.def_items.select {|itm| !itm.docs_ignored }.each do |item|
        case item
        when Extractor::GlobalVarDef
          const_name = underscore!(rb_wx_name(item.name)).upcase
          if wx_consts.has_key?(const_name)
            gen_constant_doc(fdoc, const_name, wx_consts[const_name], DocGenerator::XMLTransform.to_doc(item.brief_doc))
          end
        when Extractor::EnumDef
          enum_name = rb_wx_name(item.name)
          if const_table.has_key?(enum_name)
            gen_enum_doc(fdoc, enum_name, item, const_table[enum_name])
          end
        when Extractor::DefineDef
          if !item.is_macro? && item.value && !item.value.empty?
            const_name = underscore!(rb_wx_name(item.name)).upcase
            if wx_consts.has_key?(const_name)
              gen_constant_doc(fdoc, const_name, wx_consts[const_name], DocGenerator::XMLTransform.to_doc(item.brief_doc))
            end
          end
        end
      end
    end

    def gen_class_doc(fdoc, genspec)
      genspec.def_items.select {|itm| !itm.docs_ignored && Extractor::ClassDef === itm }.each do |item|
        if !item.is_template? || genspec.template_as_class?(item.name)
          clsnm = rb_wx_name(item.name)
          basecls = genspec.base_class(item)
          fdoc.doc.puts(DocGenerator::XMLTransform.to_doc(item.brief_doc))
          fdoc.doc.puts
          fdoc.doc.puts(XMLTransform.to_doc(item.detailed_doc))
          fdoc.puts "class #{clsnm} < #{basecls ? basecls.sub(/\Awx/, '') : '::Object'}"
          fdoc.puts
          fdoc.indent do
            item.rb_doc(fdoc)
          end
          fdoc.puts "end # #{clsnm}"
          fdoc.puts
        end
      end
    end

  end

end
