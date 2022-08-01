# rakewx.rb
# Copyright 2004-2008, wxRuby Development Team
# released under the MIT-style wxruby3 license

# Skim all the SWIG sources to detect import/include dependencies that
# should force recompiles
here = File.expand_path( File.dirname(__FILE__) ) + File::SEPARATOR
here_rx = Regexp.new( Regexp.escape(here) )
SWIG_DEPENDS = Hash.new { | h, k | h[k] = [] }

Dir.glob('swig/**/*.i') do | i |
  File.read(i).scan(/^%(?:import|include) ["'](.*?)["']\s*$/) do | dep |
    dep_file = File.expand_path( dep[0], File.dirname(i) )
    dep_file.sub!(here_rx, '')
    SWIG_DEPENDS[i] << dep_file
  end
end

# One include file is a SWIG core file (typemaps.i), not a wxRuby file;
# avoid an error with the rake package (source tar.gz) file
swigs_typemap_file = File.expand_path('typemaps.i', 'swig')
SWIG_DEPENDS['swig/typemap.i'].delete(swigs_typemap_file)

$have_good_swig = false
# Test (once) whether there is a correct version of SWIG available,
# either on the path or in the environment variable SWIG_CMD
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

  $have_good_swig = true
end

# The plain names of all normal Wx classes to be built
def all_build_classes
  ALL_CLASSES - $config.feature_info.excluded_classes($config.wx_setup_h)
end

# The plain module names of every SWIG module (in an .i file) to be built
def all_build
  all_build_classes + HELPER_CLASSES + [ MAIN_MODULE ]
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
  all_build_classes.map { | f | "#{$config.classes_dir}/#{f}.i" } +
    HELPER_CLASSES.map { | f | "#{$config.swig_dir}/#{f}.i" } +
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
file 'src/wx.cpp' => all_swig_files + SWIG_DEPENDS['swig/wx.i'] do | t |
  do_swig("swig/wx.i", "src/wx.cpp")
  post_process(t.name, 'renamer', 'fixmainmodule')
  # RubyStockObjects are loaded later, after App has been started
  need_init = all_build_classes + HELPER_CLASSES - [ 'RubyStockObjects']
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
HELPER_CLASSES.each do | helper |
  swig_file = "#{$config.swig_dir}/#{helper}.i"
  file "#{$config.src_dir}/#{helper}.cpp" => [ swig_file,
                                       *SWIG_DEPENDS[swig_file] ] do | t |
    force_mkdir($config.src_path)
    do_swig(swig_file, t.name)
    post_process(t.name, 'renamer', 'fixmodule')
  end
end

# Generate a C++ source file from a SWIG .i source file for a core class
all_build_classes.each do | cls |
  swig_file = "#{$config.classes_path}/#{cls}.i"
  file "#{$config.src_dir}/#{cls}.cpp" => [ swig_file,
                                    *SWIG_DEPENDS[swig_file] ] do | t |
    force_mkdir($config.src_path)
    do_swig(swig_file, t.name)
    post_process(t.name, 'renamer', 'fixplatform', 'fixmodule')
  end
end

# Compile an object file from a generated c++ source
cpp_src = lambda do | tn |
  tn.sub(/#{$config.obj_dir}\/(\w+)\.#{$config.obj_ext}$/) { "#{$config.src_dir}/#{$1}.cpp" }
end

rule ".#{$config.obj_ext}" => cpp_src do | t |
  force_mkdir($config.obj_path)
  sh "#{$config.cpp} -c #{$config.verbose_flag} #{$config.cppflags} " +
     "#{$config.cpp_out_flag}#{t.name} #{t.source}"
end

# Recursive dependencies
SWIG_DEPENDS.keys.grep(/swig\/\w+\.i$/).each do | dep |
  file dep => [ *SWIG_DEPENDS[dep] ]
end

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
task :swig   => all_cpp_files

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

file_data =
%{#This is generated by rake do not edit by hand!

OBJ = #{all_obj_files_and_extra_obj.join(' ')}

rakemake: $(OBJ)

#{object_rules}
}

  file = File.new("Makefile","w+")
  file.write(file_data)
end
