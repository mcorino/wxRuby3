# rakewx.rb
# Copyright 2004-2008, wxRuby Development Team
# released under the MIT-style wxruby3 license

require_relative './lib/director'
require 'pathname'

if $config.has_wxwidgets_xml?

  WXRuby3::Director.each_package do |pkg|

    swig_targets = pkg.get_swig_targets

    # file tasks for each generated SWIG module file
    swig_targets.each_pair do |mod, deps|
      file mod => deps do |t|
        pkg.extract(File.basename(t.name, '.i'))
      end
    end

    # Target to run the linker to create a final .so/.dll wxruby3 package library
    file pkg.lib_target => [*pkg.all_obj_files, *pkg.dep_libs] do | t |
      objs = $config.extra_objs + ' ' + pkg.all_obj_files.join(' ') + ' ' + pkg.dep_libs.join(' ')
      sh "#{$config.ld} #{$config.ldflags(t.name)} #{objs} #{$config.libs} #{$config.link_output_flag}#{t.name}"
    end

    # The main source module - which needs to initialize all the other modules in the package
    file pkg.initializer_src => pkg.all_swig_files do |t|
      pkg.extract(genint: false)
    end

    # Generate cpp source files from all SWIG files
    swig_targets.each_key.select {|m| m.end_with?('.i') }.each do |mod|
      file File.join($config.src_dir, File.basename(mod, '.i')+'.cpp') =>  mod do | _ |
        pkg.generate_code(mod)
      end
    end

    task :"swig_#{pkg.name.downcase}"   => [ $config.classes_path ] + pkg.all_cpp_files

    task :"compile_#{pkg.name.downcase}"   => pkg.all_obj_files

    task :"default_#{pkg.name.downcase}"   => [pkg.lib_target, *pkg.dep_libs]

    task :"doc_#{pkg.name.downcase}" => pkg.all_swig_files do
      pkg.generate_docs
    end

    task :"clean_#{pkg.name.downcase}" => pkg.subpackages.values.collect {|sp| :"clean_#{sp.name.downcase}"} do
      delete_files_in(File.join(pkg.ruby_classes_path, 'events'))
      force_rmdir(File.join(pkg.ruby_classes_path, 'events'))
      delete_files_in(File.join(pkg.ruby_classes_path, 'ext'))
      force_rmdir(File.join(pkg.ruby_classes_path, 'ext'))
      delete_files_in(pkg.ruby_doc_path)
      force_rmdir(pkg.ruby_doc_path)
    end

    task :"install_#{pkg.name.downcase}" => [ :"default_#{pkg.name.downcase}" ] do | _ |
      cp pkg.lib_target, RbConfig::CONFIG['sitearchdir']
    end

    task :"uninstall_#{pkg.name.downcase}" do | _ |
      rm_rf File.join(RbConfig::CONFIG['sitearchdir'],File.basename(pkg.lib_target))
    end
  end

  def all_swig_targets
    WXRuby3::Director.all_packages.collect {|p| "swig_#{p.name.downcase}".to_sym }
  end

  def all_compile_targets
    WXRuby3::Director.all_packages.collect {|p| "compile_#{p.name.downcase}".to_sym }
  end

  def all_default_targets
    WXRuby3::Director.all_packages.collect {|p| "default_#{p.name.downcase}".to_sym }
  end

  def all_doc_targets
    WXRuby3::Director.all_packages.collect {|p| "doc_#{p.name.downcase}".to_sym }
  end

  def all_clean_targets
    WXRuby3::Director.all_packages.collect {|p| "clean_#{p.name.downcase}".to_sym }
  end

  def all_install_targets
    WXRuby3::Director.all_packages.collect {|p| "install_#{p.name.downcase}".to_sym }
  end

  def all_uninstall_targets
    WXRuby3::Director.all_packages.collect {|p| "uninstall_#{p.name.downcase}".to_sym }
  end

  # Compile an object file from a generated c++ source
  cpp_src = lambda do | tn |
    tn.sub(/#{$config.obj_dir}\/(\w+)\.#{$config.obj_ext}$/) { "#{$config.src_dir}/#{$1}.cpp" }
  end

  rule ".#{$config.obj_ext}" => cpp_src do | t |
    sh "#{$config.cpp} -c #{$config.verbose_flag} #{$config.cppflags} #{WXRuby3::Director.cpp_flags(t.source)} " +
       "#{$config.cpp_out_flag}#{t.name} #{t.source}"
  end

  desc "Install the WxRuby library to Ruby's lib directories"
  task :install => [ :default, *ALL_RUBY_LIB_FILES, *all_install_targets ] do | t |
    dest_dir = RbConfig::CONFIG['sitelibdir']
    ALL_RUBY_LIB_FILES.each do | lib_file |
      dest = lib_file.sub(/^lib/, dest_dir)
      mkdir_p(File.dirname(dest))
      cp lib_file, dest
      chmod 0755, dest
    end
  end

  desc "Removes installed library files from site_ruby"
  task :uninstall => all_uninstall_targets do | t |
    rm_rf File.join(RbConfig::CONFIG['sitelibdir'], 'wx.rb')
    rm_rf File.join(RbConfig::CONFIG['sitelibdir'], 'wx')
  end

  desc "Generate C++ source and header files using SWIG"
  task :swig   => [ $config.classes_path ] + all_swig_targets

  desc "Force generate C++ source and header files using SWIG"
  task :reswig => [ :clean_src, :swig ]

  desc 'Generate documentation for wxRuby'
  task :doc => all_doc_targets

end
