###
# wxRuby3 Rake dependency file Generator class
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './base'

module WXRuby3

  class RakeDependencyGenerator < Generator

    def get_common_dependencies
      list = [File.join(WXRuby3::Config.instance.swig_dir, 'common.i')]
      list.concat(Director.common_dependencies[list.first])
    end
    protected :get_common_dependencies


    def wrapper_source
      File.join($config.src_dir, "#{name}.cpp")
    end
    protected :wrapper_source

    def create_rake_tasks(frake)
      wxruby_root = Pathname(WXRuby3::Config.wxruby_root)

      # determine baseclass dependencies (generated baseclass interface header) for this module
      base_deps = []
      def_items.each do |item|
        if Extractor::ClassDef === item && !item.ignored && !is_folded_base?(item.name)
          base_list(item).reverse.each do |base|
            unless def_item(base)
              base_deps << File.join(Config.instance.interface_dir, "#{base}.h")
            end
          end
        end
      end

      # setup file task with dependencies for the generated SWIG input file
      # (by making it dependent on generated baseclass interface headers we ensure ordered generation
      # which allows us to perform various interface checks while generating)
      swig_i_file = Pathname(interface_file).relative_path_from(wxruby_root).to_s
      frake << <<~__TASK__
        # file task for module's SWIG interface input file
        file '#{swig_i_file}' => ['rakefile', '#{(@director.source_files + base_deps).join("', '")}'] do |_|
          WXRuby3::Director['#{package.fullname}'].extract('#{name}')
        end
      __TASK__
      if has_interface_include?
        swig_i_h_file = Pathname(interface_include_file).relative_path_from(wxruby_root).to_s
        frake << <<~__TASK__
          # file task for module's SWIG interface header include file
          file '#{swig_i_h_file}' => '#{swig_i_file}'
        __TASK__
      end
      # determine dependencies for the SWIG generated wrapper source file
      list = [swig_i_file]
      list << swig_i_h_file if has_interface_include?
      list.concat(get_common_dependencies)
      list.concat(base_deps)

      [:prepend, :append].each do |pos|
        unless swig_imports[pos].empty?
          swig_imports[pos].each do |inc|
            # make sure all import dependencies are relative to wxruby root
            if File.exist?(File.join(WXRuby3::Config.instance.classes_path, inc))
              inc = File.join(WXRuby3::Config.instance.classes_path, inc)
              list << Pathname(inc).relative_path_from(wxruby_root).to_s
            else
              list << inc
            end
          end
        end
      end

      unless swig_includes.empty?
        swig_includes.each do |inc|
          # make sure all include dependencies are relative to wxruby root
          if File.exist?(File.join(WXRuby3::Config.instance.classes_path, inc))
            inc = File.join(WXRuby3::Config.instance.classes_path, inc)
            list << Pathname(inc).relative_path_from(wxruby_root).to_s
          else
            list << inc
          end
          list.concat(Director.common_dependencies[list.last] || [])
        end
      end

      # setup file task with dependencies for SWIG generated wrapper source file
      frake << <<~__TASK__
        # file task for module's SWIG generated wrapper source file
        file '#{wrapper_source}' => #{list} do |_|
          WXRuby3::Director['#{package.fullname}'].generate_code('#{name}')
        end
      __TASK__
    end
    protected :create_rake_tasks

    def rake_file
      @director.rake_file
    end

    def run
      # create dependencies
      Stream.transaction do
        # create dependencies file
        create_rake_tasks(CodeStream.new(rake_file))
      end
    end

  end

end
