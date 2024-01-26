# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 rake build support
###

require 'pathname'
require_relative './lib/config'

if WXRuby3.is_bootstrapped?

  Rake.application.options.always_multitask =
    Rake.application.top_level_tasks.size == 1 && Rake.application.top_level_tasks.first == 'build'

  require_relative './lib/director'

  def enum_list_cache
    unless WXRuby3::Director.validate_enum_cache
      rm_if(WXRuby3::Director.enum_cache_path, verbose: false)
      rm_if(WXRuby3::Director.enum_cache_control_path, verbose: false)
    end
    WXRuby3::Director.enum_cache_control_path
  end

  WXRuby3::Director.each_package do |pkg|

    namespace pkg.name.downcase do

      pkg.included_directors.each do |dir|
        # file tasks for each module's rake file
        file dir.rake_file  => [WXRuby3.build_cfg, *WXRuby3.config.build_paths, enum_list_cache, *dir.source_files] do |_|
          dir.create_rakefile
        end

        # imports of each module's dependency file
        import dir.rake_file
      end

      # file tasks to generate cpp wrapper sources for any extra package modules (core only)
      pkg.all_extra_modules.each do |mod|
        _deps = [File.join(WXRuby3.config.swig_dir, "#{mod}.i")]
        _deps.concat(WXRuby3::Director.common_dependencies[_deps.first])
        file File.join(WXRuby3.config.src_dir, "#{mod}.cpp") => _deps do |_|
          pkg.generate_code(mod)
        end
      end

      # The main source module - which needs to initialize all the other modules in the package
      file pkg.initializer_src => (pkg.all_swig_files + (pkg.parent ? [pkg.parent.initializer_src] : [])) do |t|
        pkg.generate_initializer
      end

      # Target to run the linker to create a final .so/.dll wxruby3 package library
      file pkg.lib_target => [*pkg.all_obj_files, *pkg.dep_libs] do | t |
        WXRuby3.config.do_link(pkg)
      end

      task :swig   => ['config:bootstrap', :build_report, :enum_list, WXRuby3.config.classes_path, *pkg.all_cpp_files]

      task :compile   => ['config:bootstrap', :build_report, *pkg.all_obj_files]

      task :build   => ['config:bootstrap', :build_report, :enum_list, pkg.lib_target, *pkg.dep_libs]

      task :clean => pkg.subpackages.values.collect {|sp| "wxruby:#{sp.name.downcase}:clean" } do
        rm_if(Dir[File.join(pkg.ruby_classes_path, 'events', '*')])
        rmdir_if(File.join(pkg.ruby_classes_path, 'events'))
        rm_if(Dir[File.join(pkg.ruby_classes_path, 'ext', '*')])
        rmdir_if(File.join(pkg.ruby_classes_path, 'ext'))
        rm_if(Dir[File.join(pkg.ruby_doc_path, '*')])
        rmdir_if(pkg.ruby_doc_path)
      end

    end # namespace

  end

  task :build_report do
    WXRuby3::Config.instance.report
  end

  task :enum_list => 'config:bootstrap' do
    Rake::Task[enum_list_cache].invoke
  end

  def all_swig_targets
    WXRuby3::Director.all_packages.collect {|p| "wxruby:#{p.name.downcase}:swig".to_sym }
  end

  def all_compile_targets
    WXRuby3::Director.all_packages.collect {|p| "wxruby:#{p.name.downcase}:compile".to_sym }
  end

  def all_build_targets
    WXRuby3::Director.all_packages.collect {|p| "wxruby:#{p.name.downcase}:build" }
  end

  def all_clean_targets
    WXRuby3::Director.all_packages.collect {|p| "wxruby:#{p.name.downcase}:clean".to_sym }
  end

  file WXRuby3::Director.enum_cache_control_path do |t_|
    WXRuby3::Director.all_packages.each { |p| p.extract(genint: false) }
    touch(WXRuby3::Director.enum_cache_control_path, verbose: !WXRuby3.config.run_silent?)
  end

  # Compile an object file from a generated c++ source
  rule ".#{WXRuby3.config.obj_ext}" => [
    proc { |tn| "#{WXRuby3.config.src_dir}/#{File.basename(tn, ".*")}.cpp" }
  ] do | t |
    WXRuby3.config.sh "#{WXRuby3.config.cpp} -c #{WXRuby3.config.verbose_flag} " +
                        "#{WXRuby3.config.cxxflags} #{WXRuby3::Director.cpp_flags(t.source)} " +
                        "#{WXRuby3.config.cpp_out_flag}#{t.name} #{t.source}",
                      fail_on_error: true
  end

  if WXRuby3.config.windows?
    # compile an object file from the standard wxRuby resource file
    file File.join(WXRuby3.config.obj_dir, 'wx_rc.o') => File.join(WXRuby3.config.swig_dir, 'wx.rc') do |t|
      WXRuby3.config.sh "#{WXRuby3.config.rescomp} -i#{t.source} -o#{t.name}", fail_on_error: true
    end
  end

else

  task :enum_list

  def all_swig_targets
    []
  end

  def all_compile_targets
    []
  end

  def all_build_targets
    []
  end

  def all_clean_targets
    []
  end

end
