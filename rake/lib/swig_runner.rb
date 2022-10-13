#--------------------------------------------------------------------
# @file    swig_runner.rb
# @author  Martin Corino
#
# @brief   wxRuby3 SWIG code generation runner
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

require_relative './streams'
require_relative './util/string'
require 'fileutils'

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

      def check_swig
        begin
          version = `#{SWIG_CMD} -version`[/\d+\.\d+\.\d+/]
        rescue
          raise "Could not run SWIG (#{SWIG_CMD})"
        end

        # Very old versions put --version on STDERR, not STDOUT
        unless version
          raise "Could not get version info from SWIG; " +
                  "is a very old version installed?.\n"
        end

        if version < SWIG_MINIMUM_VERSION
          raise "SWIG version #{version} is installed, " +
                  "minimum version required is #{SWIG_MINIMUM_VERSION}.\n"
          #  elsif version > SWIG_MAXIMUM_VERSION
          #    raise "SWIG version #{version} is installed, " +
          #          "maximum version permitted is #{SWIG_MAXIMUM_VERSION}"
        end

        @swig_state = true
      end

      def run_swig(source)
        check_swig unless swig_state
        target = File.join(config.src_path, File.basename(source, '.i') + '.cpp')
        sh "#{SWIG_CMD} #{config.wx_cppflags} -Iswig/custom " +
             #"-w401 -w801 -w515 -c++ -ruby " +
             "-w801 -c++ -ruby " +
             "-o #{target} #{source}"
        target
      end

      def run_post_processors(target, spec, *processors)
        processors.each { |pp| Processor.__send__(pp, target, spec) }
      end

    end

    def self.process(spec)
      target = run_swig(spec.interface_file)
      run_post_processors(target, spec, *spec.post_processors)
    end

    module Processor

      class << self
        include Util::StringUtil

        def collect_enumerators(spec)
          spec.def_items.select do |item|
            Extractor::EnumDef === item && !(item.name.empty? || item.name.start_with?('@'))
          end.inject({}) do |hash, enum|
            enum.items.inject(hash) { |hsh, e| hsh[rb_wx_name(e.name)] = rb_wx_name(enum.name); hsh }
          end
        end
      end

      def self.rename(target, _)
        puts "Processor.rename: #{target}"
        Stream.transaction do
          out = CodeStream.new(target)
          File.foreach(target) do |line|
            case line
            when /(rb_define_method|rb_intern|rb_define_module_function).*("[_a-zA-Z0-9]*")/
              name = $2
              unless name == '"THE_APP"'
                line[name] = '"%s"' % rb_method_name(name[1..-2])
              end
            when /rb_define_class_under.*("[_a-zA-Z0-9]*")/
              name = $1
              line[name] = '"%s"' % rb_class_name(name[1..-2])
            when /rb_define_const\s*\([^,]+,\s*("[_a-zA-Z0-9]*")/
              name = $1
              line[name] = '"%s"' % rb_wx_name(name[1..-2])
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
      end

      MAIN_MODULE = 'Wxruby3'

      def self.fixmodule(target, spec)
        puts "Processor.fixmodule: #{target}"

        enum_table = collect_enumerators(spec)

        core_name = File.basename(target, ".cpp")

        skip_entire_method = false
        brace_level = 0

        fix_enum = false
        enum_name = nil

        found_init = false

        Stream.transaction do
          out = CodeStream.new(target)
          File.foreach(target) do |line|

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

              # TODO : is this still needed?
              # Ugly: special fixes for TreeCtrl - these macros and extra funcs
              # are needed to allow user-defined sorting to work
              if core_name == "TreeCtrl"
                # default ctor needed for Swig::Director
                if line["Director(VALUE self) : swig_self(self), swig_disown_flag(false)"]
                  line = "    Director() { } // added by fixmodule.rb \n" + line
                end
                if line["SwigDirector_wxTreeCtrl::SwigDirector_wxTreeCtrl(VALUE self)"]
                  line = "IMPLEMENT_DYNAMIC_CLASS(SwigDirector_wxTreeCtrl,  wxTreeCtrl);\n" + line
                  # We also need to tweak the header file
                  treectrl_h_file = filename.sub(/cpp$/, "h")
                  contents = File.read(treectrl_h_file)
                  contents.sub!(/\};/, <<~__HEREDOC
                    private:
                    DECLARE_DYNAMIC_CLASS(SwigDirector_wxTreeCtrl);
                    };
                  __HEREDOC
                  )
                  contents.sub!(/public:/, "public:\nSwigDirector_wxTreeCtrl() {};")

                  File.open(treectrl_h_file, 'w') { |f| f.write(contents) }
                end
              end # end horrible TreeCtrl fixes

              # wxMenu has been marked 'nodirector' in it's entirety
              # # TODO : still needed?
              # # Ugly: special fixes for Menu - can be deleted by wxWidgets from
              # # the C++ side, so we need to unhook the ruby object in the dtor
              # if core_name == 'Menu' and line['~SwigDirector_wxMenu()']
              #   line += "  SWIG_RubyUnlinkObjects(this);\n  SWIG_RubyRemoveTracking(this);\n"
              # end

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
                line.sub!(/\"Wx#{core_name}::wx#{core_name}/, "\"#{MAIN_MODULE}::#{core_name}")
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
              # to the real main Wx:: module.
              if line['rb_define_module("Wx']
                line = "  mWx#{core_name} = m#{MAIN_MODULE}; // fixmodule.rb"
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

              # check for known enumerator constants
              if !fix_enum # not fixing one yet
                # have we reached the first of a known enum
                if (md = /rb_define_const\s*\(([^,]+),\s*"([_a-zA-Z0-9]*)"/.match(line))
                  if enum_table.has_key?(md[2])
                    fix_enum = true
                    enum_name = enum_table[md[2]]
                    line = [
                      '',
                      # create new enum submodule
                      "  VALUE mWx#{enum_name} = rb_define_module_under(#{md[1]}, \"#{enum_name}\"); // Inserted by fixmodule.rb",
                      # create enumerator const under new submodule
                      line.sub(/rb_define_const\s*\([^,]+,/, "rb_define_const(mWx#{enum_name},")
                    ].join("\n")
                  end
                end
              elsif (md = /rb_define_const\s*\(([^,]+),\s*"([_a-zA-Z0-9]*)"/.match(line))
                # still an enumerator?
                if enum_table.has_key?(md[2])
                  # of the same enum?
                  if enum_table[md[2]] == enum_name
                    # create enumerator const under new submodule
                    line.sub!(/rb_define_const\s*\([^,]+,/, "rb_define_const(mWx#{enum_name},")
                  else # we found the start of another enum
                    enum_name = enum_table[md[2]]
                    line = [
                      '',
                      # create new enum submodule
                      "  VALUE mWx#{enum_name} = rb_define_module_under(#{md[1]}, \"#{enum_name}\"); // Inserted by fixmodule.rb",
                      line.sub(/rb_define_const\s*\([^,]+,/, "rb_define_const(mWx#{enum_name},") # create enumerator const under new submodule
                    ].join("\n")
                  end
                else
                  enum_name = nil
                  fix_enum = false
                end
              end
            end

            out.puts(line)
          end
        end
      end

      def self.fixmainmodule(target, _)
        puts "Processor.fixmainmodule: #{target}"
        this_module = 'unknown'
        Stream.transaction do
          out = CodeStream.new(target)
          found_main_module = false
          File.foreach(target) do |line|
            if line.index("static VALUE m#{MAIN_MODULE};")
              line = "VALUE m#{MAIN_MODULE};"
              found_main_module = true
            end

            if line.index("char* type_name = RSTRING(value)->ptr;")
              line = "        const char* type_name = (value == Qnil) ? \"\" : RSTRING(value)->ptr;\n";
            end

            out.puts(line)
          end
          if !found_main_module
            puts("didn't find main module")
            exit(1)
          end
        end
      end

    end # module Processor

  end # module SwigRunner

end # module WXRuby3
