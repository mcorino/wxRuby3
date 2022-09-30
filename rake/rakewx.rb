# rakewx.rb
# Copyright 2004-2008, wxRuby Development Team
# released under the MIT-style wxruby3 license

require_relative './lib/director'
require 'pathname'

# The plain names of all normal Wx classes to be built
def all_build_modules
  WXRuby3::Director.all_modules - $config.feature_info.excluded_modules($config.wx_setup_h)
end

# The plain module names of every SWIG module (in an .i file) to be built
def all_build
  all_build_modules + $config.helper_modules + [MAIN_MODULE]
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
    $config.helper_modules.map { | f | "#{$config.swig_dir}/#{f}.i" } +
    [ 'swig/wx.i' ]
end

if $config.has_wxwidgets_xml?

  desc "(Re-)Extract all SWIG interface files (*.i) from wxWidgets XML doc files"
  task :extract do
    WXRuby3::Director.extract
  end

  # file tasks for each generated SWIG module file
  all_build_modules.each do |mod|
    file File.join($config.classes_dir, mod+'.i') do |t|
      WXRuby3::Director.extract(File.basename(t.name, '.i'))
    end
  end

  # dependency table
  $swig_depends = Hash.new { | h, k | h[k] = [] }
  # dependency file
  $depends_file = File.join($config.classes_path, '.depends')

  # file task to generate dependencies file
  file $depends_file => all_swig_files do
    # Skim all the SWIG sources to detect import/include dependencies that
    # should force recompiles
    here = Pathname(WXRuby3::Config.wxruby_root)
    # One include file is a SWIG core file (typemaps.i), not a wxRuby file;
    # avoid an error with the rake package (source tar.gz) file
    swigs_typemap_file = File.expand_path('typemaps.i', 'swig')
    File.open($depends_file, File::CREAT|File::TRUNC|File::RDWR) do |f|
      Dir.glob('swig/**/*.i') do | i |
        deps = []
        is_typemap = (i == 'typemap.i')
        File.read(i).scan(/^%(?:import|include) ["'](.*?)["']\s*$/) do | dep |
          dep_file = File.expand_path( dep[0], File.dirname(i) )
          unless is_typemap && dep_file == swigs_typemap_file
            deps << Pathname(dep_file).relative_path_from(here).to_s
          end
        end
        f.puts "$swig_depends['#{i}'] = ['#{deps.join("','")}']" unless deps.empty?
      end
    end
    # Create recursive dependencies
    $swig_depends.keys.grep(/swig\/\w+\.i$/).each do | dep |
      unless $config.include_modules.include?(dep)
        file dep => [ *($swig_depends[dep] - $config.include_modules) ]
      end
    end
  end

  import $depends_file

  # Target to run the linker to create a final .so/.dll wxruby3 library
  file TARGET_LIB => all_obj_files do | t |
    objs = $config.extra_objs + " " + all_obj_files.join(' ')
    sh "#{$config.ld} #{$config.ldflags} #{objs} #{$config.libs} #{$config.link_output_flag}#{t.name}"
  end

  # The main source module - which needs to initialize all the other modules
  init_inc = File.join($config.inc_path, 'all_modules_init.inc')
  file init_inc => :extract
  file 'src/wx.cpp' => all_swig_files + $swig_depends['swig/wx.i'] + [init_inc] do | t |
    WXRuby3::Director.generate_code('swig/wx.i', :rename, :fixmainmodule)
    File.open(t.name, "a") do | out |
      out << File.read(init_inc)
    end
  end

  # Generate cpp source from helper SWIG files - RubyConstants, Functions,
  # RubyStockObjects etc
  $config.helper_modules.each do | helper |
    swig_file = "#{$config.swig_dir}/#{helper}.i"
    file "#{$config.src_dir}/#{helper}.cpp" => [ swig_file,
                                                *($swig_depends[swig_file] - $config.include_modules) ] do | _ |
      WXRuby3::Director.generate_code(swig_file, :rename, :fixmodule)
    end
  end

  # Generate a C++ source file from a SWIG .i source file for a core class
  all_build_modules.each do | cls |
    swig_file = "#{$config.classes_path}/#{cls}.i"
    file "#{$config.src_dir}/#{cls}.cpp" => [ swig_file, *($swig_depends[swig_file] - $config.include_modules) ] do | _ |
      WXRuby3::Director.generate_code(swig_file) # default post processors
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
