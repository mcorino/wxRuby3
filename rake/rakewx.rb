# rakewx.rb
# Copyright 2004-2008, wxRuby Development Team
# released under the MIT-style wxruby3 license

require_relative './lib/director'
require 'pathname'

desc "Extract SWIG interface files (*.i) from wxWidgets XML doc files"
task :extract do
  WXRuby3::Director.extract
end

# directory task to trigger SWIG interface extraction
directory $config.classes_path => [:extract]

# Skim all the SWIG sources to detect import/include dependencies that
# should force recompiles
$swig_depends = Hash.new { | h, k | h[k] = [] }
$swig_includes = nil

def swig_depends
  if $swig_depends.empty?
    here = Pathname(WXRuby3::Config.wxruby_root)
    Dir.glob('swig/**/*.i') do | i |
      File.read(i).scan(/^%(?:import|include) ["'](.*?)["']\s*$/) do | dep |
        dep_file = File.expand_path( dep[0], File.dirname(i) )
        $swig_depends[i] << Pathname(dep_file).relative_path_from(here).to_s
      end
    end

    # One include file is a SWIG core file (typemaps.i), not a wxRuby file;
    # avoid an error with the rake package (source tar.gz) file
    swigs_typemap_file = File.expand_path('typemaps.i', 'swig')
    $swig_depends['swig/typemap.i'].delete(swigs_typemap_file)
  end
  $swig_depends
end

def swig_includes
  unless $swig_includes
    Dir.chdir(WXRuby3::Config.wxruby_root) do
      $swig_includes = (INCLUDE_MODULES.collect do |glob|
        Dir.glob(File.join($config.swig_dir, glob))
      end).flatten
    end
  end
  $swig_includes
end

# $have_good_swig = false
# # Test (once) whether there is a correct version of SWIG available,
# # either on the path or in the environment variable SWIG_CMD
# def check_swig
#   begin
#     version = `#{SWIG_CMD} -version`[/\d+\.\d+\.\d+/]
#   rescue
#     raise "Could not run SWIG (#{SWIG_CMD})"
#   end
#
#   # Very old versions put --version on STDERR, not STDOUT
#   unless version
#     raise "Could not get version info from SWIG; " +
#           "is a very old version installed?.\n"
#   end
#
#   if version < SWIG_MINIMUM_VERSION
#     raise "SWIG version #{version} is installed, " +
#           "minimum version required is #{SWIG_MINIMUM_VERSION}.\n"
# #  elsif version > SWIG_MAXIMUM_VERSION
# #    raise "SWIG version #{version} is installed, " +
# #          "maximum version permitted is #{SWIG_MAXIMUM_VERSION}"
#   end
#
#   $have_good_swig = true
# end

# The plain names of all normal Wx classes to be built
def all_build_modules
  WXRuby3::Director.all_modules - $config.feature_info.excluded_modules($config.wx_setup_h)
end

# The plain module names of every SWIG module (in an .i file) to be built
def all_build
  all_build_modules + HELPER_MODULES + [MAIN_MODULE]
end

# Every compiled object file to be linked into the final library
def all_obj_files
  all_build.map { | f | "#{$config.obj_dir}/#{f}.#{$config.obj_ext}" }
end

# Every cpp file to be compiled
def all_cpp_files
  all_build.map { | f | "#{$config.src_dir}/#{f}.cpp" }
end

# Every swig class that must be processed
def all_swig_files
  all_build_modules.map { | f | "#{$config.classes_dir}/#{f}.i" } +
    HELPER_MODULES.map { | f | "#{$config.swig_dir}/#{f}.i" } +
    [ 'swig/wx.i' ]
end

# Helper: run swig on +source+ (.i file) to generate +target+ (.cpp
# file)
def do_swig(source, target)
  check_swig if not $have_good_swig
  sh "#{SWIG_CMD} #{$config.wx_cppflags} -Iswig/custom " +
       #"-w401 -w801 -w515 -c++ -ruby " +
    "-w801 -c++ -ruby " +
    "-o #{target} #{source}"
end

# Helper: run ruby scripts over SWIG-generated .cpp file +file+, to
# provide various SWIG fixes and workarounds
def post_process(file, *processors)
  processors.each do | p |
    sh "#{$config.ruby_exe} swig/#{p}.rb #{file}"
  end
end

# Target to run the linker to create a final .so/.dll wxruby3 library
file TARGET_LIB => all_obj_files do | t |
  objs = $config.extra_objs + " " + all_obj_files.join(' ')
  sh "#{$config.ld} #{$config.ldflags} #{objs} #{$config.libs} #{$config.link_output_flag}#{t.name}"
end

# The main source module - which needs to initialize all the other modules
file 'src/wx.cpp' => all_swig_files + swig_depends['swig/wx.i'] do | t |
  WXRuby3::Director.generate_code('swig/wx.i', :rename, :fixmainmodule)
  # do_swig("swig/wx.i", "src/wx.cpp")
  # post_process(t.name, 'renamer', 'fixmainmodule')
  # RubyStockObjects are loaded later, after App has been started
  need_init = all_build_modules + HELPER_MODULES - ['RubyStockObjects']
  File.open(t.name, "a") do | out |
    out.puts
    out.puts 'extern "C" void InitializeOtherModules()'
    out.puts '{'
    # Set up an initializer for all the other compiled classes
    need_init.each do | c |
      init = "Init_wx#{c}()"
      out.puts "    extern void #{init};"
      out.puts "    #{init};"
    end
    out.puts '}'
  end
end

# Generate cpp source from helper SWIG files - RubyConstants, Functions,
# RubyStockObjects etc
HELPER_MODULES.each do | helper |
  swig_file = "#{$config.swig_dir}/#{helper}.i"
  file "#{$config.src_dir}/#{helper}.cpp" => [ swig_file,
                                              *(swig_depends[swig_file] - swig_includes) ] do | t |
    # force_mkdir($config.src_path)
    # do_swig(swig_file, t.name)
    # post_process(t.name, 'renamer', 'fixmodule')
    WXRuby3::Director.generate_code(swig_file, :rename, :fixmodule)
  end
end

# Generate a C++ source file from a SWIG .i source file for a core class
all_build_modules.each do | cls |
  swig_file = "#{$config.classes_path}/#{cls}.i"
  file "#{$config.src_dir}/#{cls}.cpp" => [ $config.classes_path, swig_file,
                                            *(swig_depends[swig_file] - swig_includes) ] do | t |
    # force_mkdir($config.src_path)
    # do_swig(swig_file, t.name)
    # post_process(t.name, 'renamer', 'fixplatform', 'fixmodule')
    WXRuby3::Director.generate_code(swig_file)
  end
end

# Compile an object file from a generated c++ source
cpp_src = lambda do | tn |
  tn.sub(/#{$config.obj_dir}\/(\w+)\.#{$config.obj_ext}$/) { "#{$config.src_dir}/#{$1}.cpp" }
end

rule ".#{$config.obj_ext}" => cpp_src do | t |
  # force_mkdir($config.obj_path)
  sh "#{$config.cpp} -c #{$config.verbose_flag} #{$config.cppflags} " +
     "#{$config.cpp_out_flag}#{t.name} #{t.source}"
end

# Recursive dependencies
swig_depends.keys.grep(/swig\/\w+\.i$/).each do | dep |
  unless swig_includes.include?(dep)
    file dep => [ *(swig_depends[dep] - swig_includes) ]
  end
end

if $config.has_wxwidgets_xml?

  desc "Install the WxRuby library to Ruby's lib directories"
  task :install => [ :default, *ALL_RUBY_LIB_FILES ] do | t |
    dest_dir = RbConfig::CONFIG['sitelibdir']
    force_mkdir File.join(dest_dir, 'wx')
    force_mkdir File.join(dest_dir, 'wx', 'classes')
    cp TARGET_LIB, RbConfig::CONFIG['sitearchdir']
    ALL_RUBY_LIB_FILES.each do | lib_file |
      dest = lib_file.sub(/^lib/, dest_dir)
      cp lib_file, dest
      chmod 0755, dest
    end
  end

  desc "Removes installed library files from site_ruby"
  task :uninstall do | t |
    rm_rf File.join(RbConfig::CONFIG['sitearchdir'],File.basename(TARGET_LIB))
    rm_rf File.join(RbConfig::CONFIG['sitelibdir'], 'wx.rb')
    rm_rf File.join(RbConfig::CONFIG['sitelibdir'], 'wx')
  end

  desc "Generate C++ source and header files using SWIG"
  task :swig   => [ $config.classes_path ] + all_cpp_files

  desc "Force generate C++ source and header files using SWIG"
  task :reswig => [ :clean_src, :swig ]

  desc "Create a makefile"
  file "Makefile" => all_swig_files do
    object_rules = ""

    all_obj_files_and_extra_obj = all_obj_files + $config.extra_objs.split(' ')
    all_obj_files_and_extra_obj.each do | o |
      obj_no_dir = o.sub('obj/','')
      rule = "#{o}: src/#{obj_no_dir.sub('.o','.cpp')}\n\t#{$config.cpp} -c #{$config.verbose_flag} #{$config.cppflags} #{$config.cpp_out_flag}$@ $^\n\n"
      object_rules << rule
    end

    file_data = <<~__HEREDOC
      #This is generated by rake do not edit by hand!
      
      OBJ = #{all_obj_files_and_extra_obj.join(' ')}
      
      rakemake: $(OBJ)
      
      #{object_rules}
    __HEREDOC

    file = File.new("Makefile","w+")
    file.write(file_data)
  end

end
