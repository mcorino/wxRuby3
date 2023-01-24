###
# wxRuby3 SWIG code generation runner
# Copyright (c) M.J.N. Corino, The Netherlands
###

require 'fileutils'

require_relative './streams'
require_relative './util/string'
require_relative './core/spec_helper'

module WXRuby3

  module SwigRunner

    SWIG_CMD = ENV['SWIG_CMD'] || "swig"
    SWIG_MINIMUM_VERSION = '3.0.12'

    class << self

      include FileUtils
      include Util::StringUtil

      private

      def config
        Config.instance
      end

      def swig_state
        !!@swig_state
      end

      def swig_version
        @swig_version
      end

      def swig_major
        (@swig_version || '').split('.').first.to_i
      end

      def check_swig
        begin
          @swig_version = `#{SWIG_CMD} -version`[/\d+\.\d+\.\d+/]
        rescue Exception
          raise "Could not run SWIG (#{SWIG_CMD})"
        end

        # Very old versions put --version on STDERR, not STDOUT
        unless @swig_version
          raise "Could not get version info from SWIG; " +
                  "is a very old version installed?.\n"
        end

        if @swig_version < SWIG_MINIMUM_VERSION
          raise "SWIG version #{@swig_version} is installed, " +
                  "minimum version required is #{SWIG_MINIMUM_VERSION}.\n"
        end

        @swig_state = true
      end

      def run_swig(source, target)
        check_swig unless swig_state
        inc_paths = '-Iswig/custom'
        inc_paths << ' -Iswig/custom/swig3' if swig_major < 4
        sh "#{SWIG_CMD} #{config.wx_cppflags} #{config.extra_cppflags} #{config.verbose_flag} #{inc_paths} " +
             #"-w401 -w801 -w515 -c++ -ruby " +
             "-w801 -c++ -ruby " +
             "-o #{target} #{source}"
      end

    end

    def self.process(director)
      target = File.join(config.src_path, '.generate', File.basename(director.spec.interface_file, '.i'))
      target_src = target+'.cpp'
      target_h = target+'.h'
      begin
        # run SWIG to generate the C++ wrapper code
        run_swig(director.spec.interface_file, target_src)
        # run the post processors to update the generated C++ code
        director.spec.post_processors.each { |pp| Processor.run(pp, director, target) }
        # relocate the finalized C++ code
        final_tgt_src = File.join(config.src_path, File.basename(target_src))
        final_tgt_h = File.join(config.src_path, File.basename(target_h))
        (FileUtils.rm_f(final_tgt_src) if File.exist?(final_tgt_src)) rescue nil
        (FileUtils.rm_f(final_tgt_h) if File.exist?(final_tgt_h)) rescue nil
        FileUtils.mv(target_src, final_tgt_src)
        FileUtils.mv(target_h, final_tgt_h)
      ensure
        FileUtils.rm_f(target_src) if File.exist?(target_src)
        FileUtils.rm_f(target_h) if File.exist?(target_h)
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

      def target_src
        @target + '.cpp'
      end

      def target_hdr
        @target + '.h'
      end

      def update_file(path, at_begin: nil, at_end: nil, &block)
        Stream.transaction do
          out = CodeStream.new(path)
          if at_begin
            if ::Proc === at_begin
              at_begin.call(out)
            else
              out.puts at_begin.to_s
            end
          end
          File.foreach(path, chomp: true) { |line| block.call(out, line) }
          if at_end
            if ::Proc === at_end
              at_end.call(out)
            else
              out.puts at_end.to_s
            end
          end
        end
      end

      def update_source(at_begin: nil, at_end: nil, &block)
        update_file(target_src, at_begin: at_begin, at_end: at_end, &block)
      end

      def update_header(at_begin: nil, at_end: nil, &block)
        update_file(target_hdr, at_begin: at_begin, at_end: at_end, &block)
      end

      public

      def run
        raise NotImplementedError
      end

      class << self
        include Util::StringUtil
      end

      def self.run(pid, director, target)
        puts "Processor.#{pid}: #{target}"
        const_get(camelize(pid.to_s)).new(director, target).run
      end

      class Rename < Processor
        def run
          update_source do |out, line|
            case line
              # defined method names
            when /(rb_define_method|rb_define_module_function|rb_define_protected_method).*("[_a-zA-Z0-9]*")/
              name = $2
              unless name == '"THE_APP"'
                line[name] = '"%s"' % rb_method_name(name[1..-2])
              end
              # director called method names
            when /rb_funcall\(swig_get_self.*rb_intern.*("[_a-zA-Z0-9]*")/
              name = $1
              line[name] = '"%s"' % rb_method_name(name[1..-2])
              # defined alias methods (original method name)
            when /rb_define_alias\s*\(.*"[_a-zA-Z0-9]+[=\?]?".*("[_a-zA-Z0-9]*")/
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
            when /rb_define_singleton_method.*("[_a-zA-Z0-9]*")/
              name = $1
              no_wx_name = name[1..-2].sub(/\Awx_?/i, '')
              if no_wx_name == no_wx_name.upcase
                line[name] = '"%s"' % rb_wx_name(name[1..-2])
              else
                line[name] = '"%s"' % rb_method_name(name[1..-2])
              end
            end
            out.puts(line)
          end
        end
      end # class Rename

      class Fixmodule < Processor

        private def collect_enumerators
          enumerators = {}
          def_items.each do |item|
            case item
            when Extractor::EnumDef
              item.items.each { |e| enumerators[rb_wx_name(e.name)] = rb_wx_name(item.name) } if item.is_type
            when Extractor::ClassDef
              item.items.select { |itm| Extractor::EnumDef === itm }.each do |enum|
                enum.items.each { |e| enumerators[rb_wx_name(e.name)] = rb_wx_name(enum.name) } if enum.is_type
              end
            end
          end
          enumerators
        end

        def run
          enum_table = collect_enumerators

          core_name = name
          core_name = 'ruby3' if /\Awx\Z/i =~ core_name

          skip_entire_method = false
          brace_level = 0

          fix_enum = false
          enum_name = nil

          found_init = false

          update_source do |out, line|
            if !found_init
              # all following fixes are applicable only before we reached the
              # Init_ function

              # Fix for TipProvider
              if core_name == 'TipProvider'
                if line[/\A\s*static\s+swig_type_info\s+_swigt__p_wxRubyTipProvider/]
                  line = "// Altered by fixmodule.rb\n" +
                    line.sub(/"_p_wxRubyTipProvider"/,
                             '"_p_wxTipProvider"')
                end
              end
              # Fix for Menu
              if core_name == 'Menu'
                if line[/\A\s*static\s+swig_type_info\s+_swigt__p_wxRubyMenu/]
                  line = "// Altered by fixmodule.rb\n" +
                    line.sub(/"_p_wxRubyMenu"/,
                             '"_p_wxMenu"')
                end
              end

              # comment out swig_up because it is defined global in every module
              if (line.index("bool Swig::Director::swig_up"))
                line = "//" + line
              end

              if line =~ /char\* type_name = (RSTRING\(value\)->ptr|RSTRING_PTR\(value\));/
                line = ""
              end
              # Patch submitted for SWIG 1.3.30
              if (line.index("if (strcmp(type->name, type_name) == 0) {"))
                line = "		if ( value != Qnil && rb_obj_is_kind_of(obj, sklass->klass) ) {"
              end
              #TODO 1.3.30
              #			end

              # Fix the class names used to determine derived/non-derived in 'initialize' ('new')
              # wrappers
              if line =~ /const\s+char\s+\*classname\s+SWIGUNUSED\s+=\s+"Wx#{core_name}::wx#{core_name}";/
                line.sub!(/\"Wx#{core_name}::wx#{core_name}/, "\"#{package.fullname}::#{core_name}")
              end

              # remove the UnknownExceptionHandler::handler method
              if line.index('void UnknownExceptionHandler::handler()')
                skip_entire_method = true
              end

              if (skip_entire_method)
                line = "//#{line}"
                if (line.index('{'))
                  brace_level += 1
                end
                if (line.index('}'))
                  brace_level -= 1
                end
                if (brace_level == 0)
                  skip_entire_method = false
                end
              end

              # at the top of our Init_ function, make sure we only initialize
              # ourselves once
              if /void\s+Init_(wx|Wx)#{core_name}\(/ =~ line
                line += "static bool initialized;\n"
                line += "if(initialized) return;\n"
                line += "initialized = true;\n"
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

              # TODO : can we improve this?
              # Fix for Event.i - because it is implemented with a custom Ruby
              # subclass, need to make this subclass SWIG info available under
              # the normal name "SWIGTYPE_p_wxEvent" as it's referenced by many
              # other classes.
              if core_name == 'Event' or core_name == 'CommandEvent'
                if line[/SWIG_TypeClientData\(SWIGTYPE_p_wxRuby(Command)?Event/]
                  line = line +
                    "  // Inserted by fixmodule.rb\n" +
                    line.sub(/SWIGTYPE_p_wxRuby(Command)?Event/,
                             "SWIGTYPE_p_wx\\1Event")
                end
              end
              # Fix for TipProvider - because it is implemented with a custom Ruby
              # subclass, need to make this subclass SWIG info available under
              # the normal name "SWIGTYPE_p_wxTipProvider" as it's referenced in
              # other places.
              if core_name == 'TipProvider'
                if line[/SWIG_TypeClientData\(SWIGTYPE_p_wxRubyTipProvider/]
                  line = line +
                    "  // Inserted by fixmodule.rb\n" +
                    line.sub(/SWIGTYPE_p_wxRubyTipProvider/,
                             "SWIGTYPE_p_wxTipProvider")
                end
              end
              # Fix for Menu - because it is implemented with a custom Ruby
              # subclass, need to make this subclass SWIG info available under
              # the normal name "SWIGTYPE_p_wxMenu" as it's referenced in
              # other places.
              if core_name == 'Menu'
                if line[/SWIG_TypeClientData\(SWIGTYPE_p_wxRubyMenu/]
                  line = line +
                    "  // Inserted by fixmodule.rb\n" +
                    line.sub(/SWIGTYPE_p_wxRubyMenu/,
                             "SWIGTYPE_p_wxMenu")
                end
              end

              # check for known enumerator constants
              if (md = /rb_define_const\s*\(([^,]+),\s*"([_a-zA-Z0-9]*)"(.*)/.match(line)) # constant definition?
                if !fix_enum # not fixing one yet
                  # have we reached the first of a known enum?
                  if enum_table.has_key?(md[2])
                    fix_enum = true
                    enum_name = enum_table[md[2]]
                    line = [
                      '',
                      # create new enum class
                      "  VALUE cWx#{enum_name} = wxRuby_CreateEnumClass(\"#{enum_name}\"); // Inserted by fixmodule.rb",
                      # add enum class constant to current module
                      "  rb_define_const(#{md[1]}, \"#{enum_name}\", cWx#{enum_name}); // Inserted by fixmodule.rb",
                      # create enumerator value const under new enum class
                      "  wxRuby_AddEnumValue(cWx#{enum_name}, \"#{md[2]}\"#{md[3]} // Updated by fixmodule.rb"
                    ].join("\n")
                  end
                else
                  # still an enumerator?
                  if enum_table.has_key?(md[2])
                    # of the same enum?
                    if enum_table[md[2]] == enum_name
                      # create enumerator value const under new enum class
                      line = "  wxRuby_AddEnumValue(cWx#{enum_name}, \"#{md[2]}\"#{md[3]} // Updated by fixmodule.rb"
                    else # we found the start of another enum
                      enum_name = enum_table[md[2]]
                      line = [
                        '',
                        # create new enum class
                        "  VALUE cWx#{enum_name} = wxRuby_CreateEnumClass(\"#{enum_name}\"); // Inserted by fixmodule.rb",
                        # add enum class constant to current module
                        "  rb_define_const(#{md[1]}, \"#{enum_name}\", cWx#{enum_name}); // Inserted by fixmodule.rb",
                        # create enumerator value const under new enum class
                        "  wxRuby_AddEnumValue(cWx#{enum_name}, \"#{md[2]}\"#{md[3]} // Updated by fixmodule.rb"
                      ].join("\n")
                    end
                  else # end of enum def
                    enum_name = nil
                    fix_enum = false
                  end
                end
              elsif fix_enum
                enum_name = nil
                fix_enum = false
              end
            end

            out.puts(line)
          end
        end

      end # class Fixmodule

    end # class Processor

  end # module SwigRunner

end # module WXRuby3
