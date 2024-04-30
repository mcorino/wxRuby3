# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 SWIG code generation runner
###

require 'fileutils'

require_relative './streams'
require_relative './util/string'
require_relative './core/spec_helper'

module WXRuby3

  module SwigRunner

    SWIG_MINIMUM_VERSION = '3.0.12'

    class << self

      include FileUtils
      include Util::StringUtil

      def swig_major
        check_swig unless swig_state
        (@swig_version || '').split('.').first.to_i
      end

      private

      def config
        Config.instance
      end

      def swig_state
        !!@swig_state
      end

      def swig_version
        check_swig unless swig_state
        @swig_version
      end

      def check_swig
        begin
          @swig_version = `#{WXRuby3::Config.get_config('swig')} -version`[/\d+\.\d+\.\d+/]
        rescue Exception
          $stderr.puts "ERROR: Could not run SWIG (#{WXRuby3::Config.get_config('swig')})"
          exit(1)
        end

        # Very old versions put --version on $stderr, not $stdout
        unless @swig_version
          $stderr.puts "Could not get version info from SWIG; " +
                        "is a very old version installed?.\n"
          exit(1)
        end

        if @swig_version < SWIG_MINIMUM_VERSION
          $stderr.puts "SWIG version #{@swig_version} is installed, " +
                        "minimum version required is #{SWIG_MINIMUM_VERSION}.\n"
          exit(1)
        end

        @swig_state = true
      end

      def run_swig(source, target)
        check_swig unless swig_state
        inc_paths = "-I#{config.wxruby_dir} -I#{config.swig_dir}/custom"
        inc_paths << " -I#{config.swig_dir}/custom/swig#{swig_major}"
        WXRuby3.config.sh "#{config.get_config('swig')} #{config.wx_cppflags.join(' ')} " +
                            "#{config.extra_cppflags.join(' ')} #{config.verbose_flag} #{inc_paths} " +
                            #"-w401 -w801 -w515 -c++ -ruby " +
                            "-w801 -c++ -ruby " +
                            "-o #{target} #{source}",
                          fail_on_error: true
      end

    end

    def self.process(director)
      target = Target.new(director.spec.interface_file)
      # run SWIG to generate the C++ wrapper code
      run_swig(director.spec.interface_file, target.source_path)
      # run the post processors to update the generated C++ code
      director.spec.post_processors.each { |pp| Processor.run(pp, director, target) }
      # commit the post processed code
      target.commit
    end

    class Target
      def initialize(interface_path)
        @target = File.join(config.src_path, '.generate', File.basename(interface_path, '.i'))
        @source_path = @target+'.cpp'
        @header_path = @target+'.h'
        # remove any stale files
        FileUtils.rm_f(@source_path) if File.exist?(@source_path)
        FileUtils.rm_f(@header_path) if File.exist?(@header_path)
        @source = nil
        @header = nil
      end

      attr_reader :source_path, :header_path

      def config
        Config.instance
      end
      private :config

      def source
        unless @source
          @source = File.readlines(source_path, chomp: true)
        end
        @source
      end

      def header
        unless @header
          @header = File.readlines(header_path, chomp: true)
        end
        @header
      end

      def commit
        # update the generated C++ code with the post processed code
        Stream.transaction do
          if @source
            out = CodeStream.new(source_path)
            out.puts(@source)
          end
          if @header
            out = CodeStream.new(header_path)
            out.puts(@header)
          end
        end
        # relocate the finalized C++ code
        final_tgt_src = File.join(config.src_path, File.basename(source_path))
        final_tgt_h = File.join(config.src_path, File.basename(header_path))
        (FileUtils.rm_f(final_tgt_src) if File.exist?(final_tgt_src)) rescue nil
        (FileUtils.rm_f(final_tgt_h) if File.exist?(final_tgt_h)) rescue nil
        FileUtils.mv(header_path, final_tgt_h)
        FileUtils.mv(source_path, final_tgt_src)
      end

      def to_s
        @target
      end
    end

    class Processor

      include DirectorSpecsHelper

      def initialize(director, target)
        @director = director
        @target = target
      end

      attr_reader :director

      protected

      def collect_result(o)
        [o].flatten.compact.collect { |s| s.split("\n") }
      end

      def update_lines(lines, at_begin: nil, at_end: nil, &block)
        result = []
        result << collect_result(::Proc === at_begin ? at_begin.call : at_begin.to_s) if at_begin
        lines.each { |line| result << collect_result(block.call(line)) }
        result << collect_result(::Proc === at_end ? at_end.call : at_end.to_s) if at_end
        result.flatten! # flatten final results
        result
      end

      def update_source(at_begin: nil, at_end: nil, &block)
        result = update_lines(@target.source, at_begin: at_begin, at_end: at_end, &block)
        @target.source.replace(result)
      end

      def update_header(at_begin: nil, at_end: nil, &block)
        result = update_lines(@target.header, at_begin: at_begin, at_end: at_end, &block)
        @target.header.replace(result)
      end

      public

      def run
        raise NotImplementedError
      end

      def to_s
        "#{self.class.name}<#{@director.module_name}@#{@director.package.name}>"
      end

      def inspect
        to_s
      end

      class << self
        include Util::StringUtil
      end

      def self.run(pid, director, target)
        Config.instance.log_progress("Processor.#{pid}: #{target}")
        const_get(camelize(pid.to_s)).new(director, target).run
      end

      class Rename < Processor
        def run
          update_source do |line|
            case line
              # defined method names
            when /(rb_define_method|rb_define_module_function|rb_define_protected_method).*("[_a-zA-Z0-9]*[=\?\!]?")/
              name = $2
              unless name == '"THE_APP"'
                line[name] = '"%s"' % rb_method_name(name[1..-2])
              end
              # director called method names
            when /rb_funcall\(swig_get_self.*rb_intern.*("[_a-zA-Z0-9]*")/
              name = $1
              line['rb_funcall'] = 'wxRuby_Funcall'
              line[name] = '"%s"' % rb_method_name(name[1..-2])
              # director output exceptions
            when /Swig::DirectorTypeMismatchException::raise\(swig_get_self\(\),\s+\"(\w+)\"/
              name = $1
              line[%Q{"#{name}"}] = %Q{"#{rb_method_name(name)}"}
              # defined alias methods (original method name)
            when /rb_define_alias\s*\(.*"[_a-zA-Z0-9]+[=\?]?".*("[_a-zA-Z0-9]*[=\?\!]?")/
              name = $1
              line[name] = '"%s"' % rb_method_name(name[1..-2])
              # defined class names
            when /rb_define_class_under.*("[_a-zA-Z0-9]*")/
              name = $1
              line[name] = '"%s"' % rb_class_name(name[1..-2])
              # defined constant names
            when /rb_define_const\s*\([^,]+,\s*("[_a-zA-Z0-9]*")/
              name = $1
              line[name] = '"%s"' % rb_wx_name(name[1..-2])
              # defined class/global methods
            when /rb_define_singleton_method.*("[_a-zA-Z0-9]*[=\?\!]?")/
              name = $1
              no_wx_name = name[1..-2].sub(/\Awx_?/i, '')
              if no_wx_name == no_wx_name.upcase
                line[name] = '"%s"' % rb_wx_name(name[1..-2])
              else
                line[name] = '"%s"' % rb_method_name(name[1..-2])
              end
            end
            line
          end
        end
      end # class Rename

      class Fixmodule < Processor

        def collect_enumerators
          enumerators = {}
          def_items.each do |item|
            case item
            when Extractor::EnumDef
              item.items.each { |e| enumerators["#{rb_wx_name(item.name)}_#{e.name}"] = item } if item.is_type
            when Extractor::ClassDef
              item.items.select { |itm| Extractor::EnumDef === itm && itm.is_type }.each do |enum|
                if enum.strong
                  enum_pfx = rb_wx_name(enum.name)
                  enum.items.each { |e| enumerators["#{enum_pfx}_#{rb_wx_name(e.name)}"] = enum }
                else
                  enum.items.each { |e| enumerators[rb_wx_name(e.name)] = enum }
                end
              end
            end
          end
          enumerators
        end
        private :collect_enumerators

        def run
          enum_table = collect_enumerators

          core_name = name
          core_name = 'ruby3' if /\Awx\Z/i =~ core_name

          fix_enum = false
          enum_item = nil

          found_init = false

          update_source do |line|
            if !found_init
              # all following fixes are applicable only before we reached the
              # Init_ function

              # Fix the class names used to determine derived/non-derived in 'initialize' ('new')
              # wrappers
              if line =~ /const\s+char\s+\*classname\s+SWIGUNUSED\s+=\s+"Wx#{core_name}::wx(\w+)";/
                line.sub!(/\"Wx#{core_name}::wx#{$1}/, "\"#{package.fullname}::#{$1}")
              end

              # check for default reference value initializations based on temporary objects
              # (prevent dangling references)
              if line =~ /^(\s+)(wx\w+)\s+const\s+\&(\w+_defvalue)\s+=\s+(.*);$/

                def_pfx = $1
                def_type = $2
                def_var = $3
                def_val = $4.strip
                if def_type == 'wxString'
                  if def_val =~ /(wxString|_|wxGetTranslation)?\(?\"[^\"]*\"\)?/
                    line = "#{def_pfx}#{def_type} #{def_var} = #{def_val};"
                  end
                elsif def_val =~ /^#{def_type}\(.*\)/
                  line = "#{def_pfx}#{def_type} #{def_var} = #{def_val};"
                end

              # at the top of our Init_ function, make sure we only initialize
              # ourselves once
              elsif /void\s+Init_(wx|Wx)#{core_name}\(/ =~ line
                line += "\n  static bool initialized;\n"
                line += "  if(initialized) return;\n"
                line += "  initialized = true;\n"
                found_init = true # switch to init fixes
              end

            else
              # all following fixes are part of the Init_ function and so
              # only need to be checked after that function has been started

              # Instead of defining a new module, set the container module equal
              # to the package module.
              if line['rb_define_module("Wx']
                line = "  mWx#{core_name} = #{package.module_variable}; // fixmodule.rb"
                found_define_module = true
                # elsif line['rb_define_module("Defs']
                #   line = "  m#{core_name} = m#{MAIN_MODULE}; // fixmodule.rb"
                #   found_define_module = true
              end

              # As a class is initialised, store a global mapping from it to the
              # correct SWIGTYPE; see wx.i
              if line =~ /SWIG_TypeClientData\((SWIGTYPE_p_\w+),\s+
                \(void\s\*\)\s+&(\w+)\)/x

                line << "\n  wxRuby_SetSwigTypeForClass(#{$2}.klass, #{$1});"
              end

              # check for known enumerator constants
              if (md = /rb_define_const\s*\(([^,]+),\s*"([_a-zA-Z0-9]*)"(.*)/.match(line)) # constant definition?
                if !fix_enum # not fixing one yet
                  # have we reached the first of a known enum?
                  if enum_table.has_key?(md[2])
                    fix_enum = true
                    enum_item = enum_table[md[2]]
                    enum_name = rb_wx_name(enum_item.name)
                    enumerator_name = rb_wx_name(md[2].sub(/\A#{enum_name}_/, ''))
                    enum_id = enum_item.scope.empty? ? enum_name : "#{rb_wx_name(enum_item.scope)}::#{enum_name}"
                    enum_var = enum_id.gsub('::', '_')
                    line = [
                      '',
                      # create new enum class (use scoped id)
                      "  VALUE cWx#{enum_var} = wxRuby_CreateEnumClass(\"#{enum_id}\"); // Inserted by fixmodule.rb",
                      # add enum class constant to current module (use unscoped name)
                      "  rb_define_const(#{md[1]}, \"#{enum_name}\", cWx#{enum_var}); // Inserted by fixmodule.rb",
                      # create enumerator value const under new enum class
                      "  wxRuby_AddEnumValue(cWx#{enum_var}, \"#{enumerator_name}\"#{md[3]} // Updated by fixmodule.rb"
                    ].join("\n")
                  end
                else
                  # still an enumerator?
                  if enum_table.has_key?(md[2])
                    # of the same enum?
                    if enum_item && enum_table[md[2]] == enum_item
                      enum_name = rb_wx_name(enum_item.name)
                      enumerator_name = rb_wx_name(md[2].sub(/\A#{enum_name}_/, ''))
                      enum_id = enum_item.scope.empty? ? enum_name : "#{rb_wx_name(enum_item.scope)}::#{enum_name}"
                      enum_var = enum_id.gsub('::', '_')
                      # create enumerator value const under new enum class
                      line = "  wxRuby_AddEnumValue(cWx#{enum_var}, \"#{enumerator_name}\"#{md[3]} // Updated by fixmodule.rb"
                    else # we found the start of another enum
                      enum_item = enum_table[md[2]]
                      enum_name = rb_wx_name(enum_item.name)
                      enumerator_name = rb_wx_name(md[2].sub(/\A#{enum_name}_/, ''))
                      enum_id = enum_item.scope.empty? ? enum_name : "#{rb_wx_name(enum_item.scope)}::#{enum_name}"
                      enum_var = enum_id.gsub('::', '_')
                      line = [
                        '',
                        # create new enum class (use scoped id)
                        "  VALUE cWx#{enum_var} = wxRuby_CreateEnumClass(\"#{enum_id}\"); // Inserted by fixmodule.rb",
                        # add enum class constant to current module (use unscoped name)
                        "  rb_define_const(#{md[1]}, \"#{enum_name}\", cWx#{enum_var}); // Inserted by fixmodule.rb",
                        # create enumerator value const under new enum class
                        "  wxRuby_AddEnumValue(cWx#{enum_var}, \"#{enumerator_name}\"#{md[3]} // Updated by fixmodule.rb"
                      ].join("\n")
                    end
                  else # end of enum def
                    enum_item = nil
                    fix_enum = false
                  end
                end
              elsif fix_enum
                enum_name = nil
                fix_enum = false
              end
            end

            line
          end
        end

      end # class Fixmodule

      # replaces SWIG generated class names used as Director base (if any) and for Ruby 'new' (initialize) function
      class FixClassImplementation < Processor
        def run
          # get the generated (class) items for which an alternate implementation has been registered
          class_list = def_items.select { |itm| Extractor::ClassDef === itm && itm.name != class_implementation(itm.name) }
          # create re match list for class names
          cls_re_txt = class_list.collect { |clsdef| clsdef.name }.join('|')
          # updating any matching alloc functions in generated SWIG sourcecode
          # create regexp for 'initialize' wrappers (due to overloads this could be more than one per class)
          new_re = /_wrap_new_(#{cls_re_txt})\w*\(.*\)/
          # check if any of the selected classes have a Director proxy enabled
          if proxies_enabled = class_list.any? { |clsdef| has_proxy?(clsdef) }
            # create re match list for classes with director proxy enabled
            dir_cls_re_txt = class_list.select { |clsdef| has_proxy?(clsdef) }.collect { |cd| cd.name }.join('|')
            # create regexp for Director constructors (may not exist if no proxies are enabled)
            dir_ctor_re = /SwigDirector_\w+::SwigDirector_\w+\(.*\)\s*:\s*(#{dir_cls_re_txt})\(.*\)\s*,\s*Swig::Director.*{/
            # create regexp for method wrappers other than 'initialize' wrappers
            wrap_mtd_re = /_wrap_(#{cls_re_txt})_(\w+)\(.*\)/
          end
          found_new = false
          cpp_class = nil
          cpp_new_re = nil
          found_wrap_mtd = false
          wrap_mtd_name = nil
          wrap_mtd_upcall_re = nil
          update_source do |line|
            if found_new # inside 'initialize' wrapper?
              if cpp_new_re =~ line # at C++ allocation of class instance?
                if $1 # director allocation for derived class
                  # in case of copy ctor replace type of argument
                  # for director copy ctor
                  line.sub!(/\((\w+),\s*\(#{cpp_class}\s+const\s+\&\)/, "(\\1,(#{class_implementation(cpp_class)} const &)")
                else # allocation for actual class
                  # replace with the registered implementation class
                  line.sub!(/new\s+#{cpp_class}\(/, "new #{class_implementation(cpp_class)}(")
                  # in case of copy ctor also replace type of argument
                  # for class copy ctor
                  line.sub!(/\(\(#{cpp_class}\s+const\s+\&\)/, "((#{class_implementation(cpp_class)} const &)")
                end
              elsif /\A}/ =~ line # end of wrapper function?
                # stop matching (in case of overloads there will be one matching wrapper function
                # that does no actual allocation but just acts as a front for the overload wrappers)
                found_new = false
              end
            elsif found_wrap_mtd
              if wrap_mtd_upcall_re =~ line # at upcall for possibly proxied wrapper?
                line.gsub!(cpp_class, class_implementation(cpp_class))
                # if the upcall does not yet cast the receiver instance to the correct implementation class
                if /\((\w+)\)->/ =~ line
                  # add required cast
                  line.sub!(/\((\w+)\)->/, "((#{class_implementation(cpp_class)} *)\\1)->")
                end
                found_wrap_mtd = false # upcall found
              elsif /\A}/ =~ line
                found_wrap_mtd = false # end of wrapper method
              end
            elsif new_re =~ line # are we at an 'initialize' wrapper?
              found_new = true
              cpp_class = $1
              cpp_new_re = /new\s+(SwigDirector_)?#{cpp_class}\(.*\)/ # regexp for C++ new expression for this specific class
            elsif proxies_enabled
              if dir_ctor_re =~ line # at director ctor?
                # replace base class name by implementation name
                cpp_class = $1
                line.sub!(/:\s*#{cpp_class}\(/, ": #{class_implementation(cpp_class)}(")
                # in case of copy ctor also replace type of argument
                line.sub!(/\(VALUE\s+self,\s*#{cpp_class}\s+const\s+\&(\w+)\)/, "(VALUE self, #{class_implementation(cpp_class)} const &\\1)")
              elsif wrap_mtd_re =~ line # at wrapper method other than 'initialize' wrapper
                cpp_class = $1
                wrap_mtd_name = $2
                wrap_mtd_upcall_re = /-\>#{cpp_class}::#{wrap_mtd_name}\(/
                found_wrap_mtd = true
              end
            end
            line
          end
          # check if any of the selected classes have a Director proxy enabled
          if proxies_enabled
            # if so, we also need to update the header code (Director class declaration)
            # create regexp for 'initialize' wrappers (due to overloads this could be more than one per class)
            dir_re = /class\s+SwigDirector_\w+\s*:\s*public\s+(#{dir_cls_re_txt})\s*,\s*public\s+Swig::Director\s*{/
            found_dir = false
            copy_ctor_re = nil
            update_header do |line|
              if found_dir
                if copy_ctor_re =~ line
                  # replace copy ctor arg type
                  arg = $1
                  line.sub!(/#{cpp_class}\s+const\s+&#{arg}/, "#{class_implementation(cpp_class)} const &#{arg}")
                elsif /\A};/ =~ line
                  found_dir = false
                end
              elsif dir_re =~ line # at Director class declaration?
                # replace base class name by implementation name
                cpp_class = $1
                line.sub!(/public\s+#{cpp_class}/, "public #{class_implementation(cpp_class)}")
                copy_ctor_re = /SwigDirector_#{cpp_class}\(VALUE\s+self,\s*#{cpp_class}\s+const\s+&(\w+)\);/
                found_dir = true
              end
              line
            end
          end
        end
      end

      # Updates SWIG generated wrapper code for disowned allocation modules.
      class FixDisownedAlloc < Processor

        def run
          # get the generated (class) items which have been defined to need disowned allocation
          class_list = def_items.select { |itm| Extractor::ClassDef === itm && allocate_disowned?(itm) }
          # setup a table with the required tracking methods for each class
          track_table = class_list.inject({}) do |tbl, clsdef|
            tbl[clsdef.name] = (gc_type(clsdef) == :GC_MANAGE_AS_UNTRACKED) ? '0' : 'SWIG_RubyRemoveTracking'
            tbl
          end
          # create re match list for class names
          cls_re_txt = class_list.collect { |clsdef| clsdef.name }.join('|')
          # updating any matching alloc functions in generated SWIG sourcecode
          # create regexp for 'initialize' wrappers (due to overloads this could be more than one per class)
          alloc_re = /_wrap_(#{cls_re_txt})_allocate\(int\s+argc.*\)/
          found_alloc = false
          cpp_class = nil
          update_source do |line|
            if found_alloc # inside 'xxx_allocate' wrapper?
              if line =~ /\A(\s*)return\s+vresult;/
                # insert an override for the free method to disown the new instance
                line = "#{$1}RDATA(vresult)->dfree = #{track_table[cpp_class]};\n#{line}"
              elsif /\A}/ =~ line # end of wrapper function?
                # stop matching
                found_alloc = false
              end
            elsif alloc_re =~ line # are we at an 'xxx_allocate' wrapper?
              found_alloc = true
              cpp_class = $1
            end
            line
          end
        end

      end

      # Updates SWIG generated wrapper code for Mixin modules.
      class FixInterfaceMixin < Processor

        def run
          # get the generated (class) items which have been defined to be mixins
          class_list = def_items.select { |itm| Extractor::ClassDef === itm && is_mixin?(itm) }
          # create re match list for class names
          cls_re_txt = class_list.collect { |clsdef| rb_wx_name(clsdef.name) }.join('|')
          skip_method = false
          skip_conversion = false
          update_source do |line|
            if skip_method
              skip_method = false if /\A}\s*\Z/ =~ line # end of function?
              line = nil # remove line in output
            else
              # transform conversion of 'self' in wrapper functions
              if /\A(\s*)res1\s*=\s*SWIG_ConvertPtr\(self,\s*&(\w+),\s*SWIGTYPE_p_wx(#{cls_re_txt})/ =~ line
                line = "#{$1}res1 = wxRuby_ConvertTo#{$3}(self, &#{$2});"
              elsif /\A(\s*)int\s+(\w+)\s*=\s*SWIG_ConvertPtr\(argv\[0\],\s*&(\w+),\s*SWIGTYPE_p_wx(#{cls_re_txt})/ =~ line
                line = "#{$1}int #{$2} = wxRuby_ConvertTo#{$4}(argv[0], &#{$3});"
                # remove unwanted function definitions
              elsif /\Afree_wx(#{cls_re_txt})/ =~ line
                line = "free_wx#{$1}() {}"
                skip_method = true
                # replace the class creation by a module creation
              elsif /\A(\s*SwigClassWx(#{cls_re_txt}).klass\s*=\s*)rb_define_class_under\(\s*(\w+)\s*,\s*\"(\w+)\"/ =~ line
                line = %Q{#{$1}rb_define_module_under(#{$3}, "#{$4}");}
                # remove the alloc undef line
              elsif /\A\s*rb_undef_alloc_func\s*\(SwigClassWx(#{cls_re_txt}).klass/ =~ line
                line = nil
                # as well as the lifecycle method setups
              elsif /\A\s*SwigClassWx(#{cls_re_txt})\.(mark|destroy|trackObjects)\s*=/ =~ line
                line = nil
              end
            end
            line
          end
        end
      end

      # Provides public access overrides in director proxies for non-virtual protected members
      # and updates wrapper methods to call public accessors in case of derived classes
      class FixProtectedAccess < Processor

        # collect the definitions of protected members that need public overrides for each class in the module
        def collect_methods
          cls_list = def_classes.select { |c| !c.ignored && (!c.is_template? || template_as_class?(c.name)) && !is_folded_base?(c.name) }
          cls_list.inject({}) do |hash, clsdef|
            intf_class_name = if (clsdef.is_template? && template_as_class?(clsdef.name))
                                template_class_name(clsdef.name)
                              else
                                clsdef.name
                              end
            InterfaceAnalyzer.check_for_interface(intf_class_name, package)
            mtds = InterfaceAnalyzer.class_interface_members_public(intf_class_name).collect do |member|
              member = if ::String === member
                         InterfaceAnalyzer.class_interface_extension_methods(intf_class_name)[member.tr("\n", '')]
                       elsif Extractor::MethodDef === member || Extractor::MemberVarDef
                         member
                       else
                         nil
                       end
              if member && needs_public_override?(clsdef, member)
                member
              else
                nil
              end
            end.compact
            hash[rb_wx_name(class_name(clsdef))] = mtds unless mtds.empty?
            hash
          end
        end

        def run
          member_map = collect_methods rescue $!
          return if member_map.empty?

          # create re match list for class names
          cls_re_txt = member_map.keys.join('|')
          cls_re = /class\s*SwigDirector_wx(#{cls_re_txt})\s*:/
          at_director = false
          class_nm = nil

          # update the SWIG generated director proxy class with the public overrides (inlines)
          update_header do |line|
            if at_director
              # find end of class declaration
              if /\A};/ =~ line
                at_director = false
                # prepend inline public accessors for protected members
                decls = member_map[class_nm].collect do |mdef|
                  if Extractor::MethodDef === mdef
                    [
                      "    #{mdef.type} #{mdef.name}_Public#{mdef.args_string} {",
                      "        #{mdef.type == 'void' ? '' : 'return '}#{mdef.name}(#{mdef.parameters.collect {|p| p.name }.join(',')});",
                      '    }'
                    ]
                  else
                    [
                      "    #{mdef.type} & #{mdef.name}_Public() {",
                      "        return #{mdef.name};",
                      '    }'
                    ]
                  end
                end.flatten
                line = (decls << line)
              end
            # find start of director class
            elsif cls_re =~ line
              at_director = true
              class_nm = $1
            end
            line
          end

          wrapper_re = /_wrap_wx(#{cls_re_txt})_(\w+)\(.*\)\s*{/
          mtd_call_re = nil
          at_wrapper = false
          at_setter = false
          matched_wrapper = false
          mtd_nm = nil
          mdef = nil

          # update the SWIG generated wrapper code to use the public overrrides and declare the wrapper methods
          # as protected
          update_source do |line|
            if at_wrapper
              if /\A}/ =~ line
                at_wrapper = false
                matched_wrapper = false
              elsif matched_wrapper && mtd_call_re =~ line
                prefix = $1
                line = [
                  "#{prefix}fpa_dir = dynamic_cast<Swig::Director *>(arg1);",
                  "#{prefix}fpa_upcall = (fpa_dir && (fpa_dir->swig_get_self() == self));",
                  "#{prefix}if (fpa_upcall)"
                ]
                if Extractor::MethodDef === mdef
                  dir_instance = if mdef.is_const
                                   "dynamic_cast<const SwigDirector_wx#{class_nm}*> ((const Swig::Director*)fpa_dir)"
                                 else
                                   "dynamic_cast<SwigDirector_wx#{class_nm}*> (fpa_dir)"
                                 end
                  if mdef.type == 'void'
                    line << "#{prefix}    #{dir_instance}->#{mtd_nm}_Public#{$2};"
                  else
                    line << "#{prefix}    result = (#{mdef.type})#{dir_instance}->#{mtd_nm}_Public#{$2};"
                  end
                elsif at_setter
                  assignment = $2
                  dir_instance = "dynamic_cast<SwigDirector_wx#{class_nm}*> (fpa_dir)"
                  line << "#{prefix}    #{dir_instance}->#{mdef.name}_Public()#{assignment};"
                  at_setter = false
                else
                  dir_instance = "dynamic_cast<SwigDirector_wx#{class_nm}*> (fpa_dir)"
                  line << "#{prefix}    result = #{dir_instance}->#{mdef.name}_Public();"
                end
                line.concat [
                              "#{prefix}else",
                              "#{prefix}    rb_raise(rb_eRuntimeError, \"Invalid access attempt for protected method.\");"
                            ]
                matched_wrapper = false
              end
            # find start of a wrapper method
            elsif wrapper_re =~ line
              class_nm = $1
              mtd_nm = $2
              at_wrapper = true
              if (mdef = member_map[class_nm].detect { |m| Extractor::MethodDef === m && (m.rb_name || m.name) == mtd_nm })
                matched_wrapper = true
                mtd_call_re = /(\s*)\S.*arg1\)?->#{mtd_nm}(\(.*\));/
                line = [line, '  bool fpa_upcall = false;', '  Swig::Director *fpa_dir = 0;']
              elsif (mdef = member_map[class_nm].detect { |m| Extractor::MemberVarDef === m && "#{m.rb_name || m.name}_get" == mtd_nm })
                matched_wrapper = true
                mtd_call_re = /(\s*)\S.*arg1\)?->#{mdef.name}\)?;/
                line = [line, '  bool fpa_upcall = false;', '  Swig::Director *fpa_dir = 0;']
              elsif (mdef = member_map[class_nm].detect { |m| Extractor::MemberVarDef === m && "#{m.rb_name || m.name}_set" == mtd_nm })
                matched_wrapper = true
                at_setter = true;
                mtd_call_re = /(\s*)\S.*arg1\)?->#{mdef.name}(\s*=\s*.*);/
                line = [line, '  bool fpa_upcall = false;', '  Swig::Director *fpa_dir = 0;']
              end
            elsif /rb_define_method\(SwigClassWx(#{cls_re_txt}).klass\s*,\s*"(\w+)(=)?"\s*,\s*VALUEFUNC/ =~ line
              class_nm = $1
              mtdnm = $2
              if member_map[class_nm].any? { |m| mtdnm == rb_method_name(m.rb_name || m.name) }
                line.sub!('rb_define_method', 'rb_define_protected_method')
              end
            end
            line
          end
        end
      end

    end # class Processor

  end # module SwigRunner

end # module WXRuby3
