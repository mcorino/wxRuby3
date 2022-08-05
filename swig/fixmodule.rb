# fixmodule.rb
# Copyright 2004-2008 wxRuby Development Team
# Released under the MIT-style wxruby2 license

# This script post-processes the SWIG output to allow a single Ruby
# module to be defined across multiple SWIG modules - ie so that all
# the Wx classes are defined within the Wx:: module, and have the
# correct inheritance hierarchy.
#
# It also fixes a number of other problems with SWIG's output

require './swig/classes/include/parents'

# $swig_class_prefix = "c"          # For SWIG versions <= 1.3.38
$swig_class_prefix = "SwigClass"  # For newer versions of SWIG

def fixmodule(filename)
  broken = filename+".old"
  File.rename(filename, broken)

  # found_swig_class = false
  found_define_module = false
  found_init = false
  # found_define_class = false

  core_name = File.basename(filename, ".cpp")
  puts "Class: #{core_name}"
  wx_name = "wx" + core_name
  parent_wxklass = $parents[wx_name]
  if parent_wxklass
    parent_name = parent_wxklass[2..-1]
    puts("      : #{parent_name}")
  end

  skip_until_blank_line = false
  skip_entire_method = false
  brace_level = 0

  File.open(filename, "w") do | out |

    File.foreach(broken) do | line |

      # if we find the definition of our class variable,
      # if (line.index("swig_class #{$swig_class_prefix}") and not line.index("extern"))
      #   puts("class #{wx_name}")
      #   # declare our (primary) base class so we can use it as our parent
      #   result = []
      #   if (parent_wxklass)
      #     result << "extern swig_class #{$swig_class_prefix}Wx#{parent_name};"
      #   end
      #   result << line
      #   line = result.join("\n")
      #   found_swig_class = true
      # end

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
          contents.sub!(/\};/, "private:
DECLARE_DYNAMIC_CLASS(SwigDirector_wxTreeCtrl);
};")
          contents.sub!(/public:/, "public:
    SwigDirector_wxTreeCtrl() {} ;")

          File.open(treectrl_h_file, 'w') { | f | f.write(contents) }
        end
      end # end horrible TreeCtrl fixes

      # Ugly: special fixes for Menu - can be deleted by wxWidgets from
      # the C++ side, so we need to unhook the ruby object in the dtor
      if core_name == 'Menu' and line['~SwigDirector_wxMenu()']
        line += "  SWIG_RubyUnlinkObjects(this);\n  SWIG_RubyRemoveTracking(this);\n"
      end


      # comment out swig_up because it is defined global in every module
      if(line.index("bool Swig::Director::swig_up"))
        line = "//" + line
      end

      if line =~ /char\* type_name = (RSTRING\(value\)->ptr|RSTRING_PTR\(value\));/
        line = ""
      end
      # Patch submitted for SWIG 1.3.30
      if(line.index("if (strcmp(type->name, type_name) == 0) {"))
        line = "		if ( value != Qnil && rb_obj_is_kind_of(obj, sklass->klass) ) {"
      end
      #TODO 1.3.30
      #			end

      # Instead of defining a new module, set the container module equal
      # to the real main Wx:: module.
      if line['rb_define_module("Wx']
        line = "  mWx#{core_name} = #{$main_module}; // fixmodule.rb"
        found_define_module = true
      end

      # at the top of our Init_ function, make sure we only initialize
      # ourselves once
      if(line.index("Init_#{wx_name}("))
        line += "static bool initialized;\n"
        line += "if(initialized) return;\n"
        line += "initialized = true;\n"
        found_init = true
      end

      # if we are defining ourselves as a subclass,
      # if(line.index("rb_define_class_under(mWx#{core_name}"))
      #   result = []
      #   if(parent_wxklass)
      #     #initialize our primary parent
      #     result << "    extern void Init_wx#{parent_name}();"
      #     result << "    Init_wx#{parent_name}();"
      #     result << "    //extern swig_class #{$swig_class_prefix}Wx#{parent_name};"
      #     parent_klass = "#{$swig_class_prefix}Wx#{parent_name}.klass"
      #     # define us under our parent instead of under ruby's Object
      #     line = line.gsub(/rb_cObject/, parent_klass)
      #   end
      #   result << line
      #   line = result.join("\n")
      #   found_define_class = true
      # end

      # As a class is initialised, store a global mapping from it to the
      # correct SWIGTYPE; see wx.i
      if line =~ /SWIG_TypeClientData\((SWIGTYPE_p_\w+),\s+
                  \(void\s\*\)\s+&(\w+)\)/x

        line << "\n  wxRuby_SetSwigTypeForClass(#{$2}.klass, #{$1});"
      end

      # # if this module doesn't have a class,
      # if(line.index('//NO_CLASS'))
      #   # pretend we found one
      #   found_swig_class = true
      #   found_define_class = true
      # end

      # remove the UnknownExceptionHandler::handler method
      if(line.index('void UnknownExceptionHandler::handler()'))
        skip_entire_method = true
      end


      if(skip_entire_method)
        line = "//#{line}"
        if(line.index('{'))
          brace_level += 1
        end
        if(line.index('}'))
          brace_level -= 1
        end
        if(brace_level == 0)
          skip_entire_method = false
        end
      end

      if(skip_until_blank_line)
        if(line.strip.size == 0)
          skip_until_blank_line = false
        else
          line = '// ' + line
        end
      end

      out.puts(line)
    end
  end

  # if(!found_swig_class)
  #   puts("ERROR! #{__FILE__} Didn't find swig class")
  #   exit(1)
  # end

  if(!found_define_module)
    puts("ERROR! #{__FILE__} Didn't find define module")
    exit(1)
  end

  if(!found_init)
    puts("ERROR! #{__FILE__} Didn't find init")
    exit(1)
  end

  # if(!found_define_class)
  #   puts("ERROR! #{__FILE__} Didn't find define class")
  #   exit(1)
  # end

  File.delete(broken)
end

$main_module = 'mWxruby3'
fixmodule(ARGV[0])
