###
# wxRuby3 rake file
# Copyright (c) M.J.N. Corino, The Netherlands
###

if WXRuby3.is_bootstrapped?

  require_relative './gem'

  namespace :wxruby do

    namespace :gem do

      task :srcgem => [WXRuby3::Gem.gem_file('wxruby3', WXRuby3::WXRUBY_VERSION)]

      task :bingem => [File.join(WXRuby3.config.rb_docgen_path, 'window.rb'), WXRuby3::Gem.gem_file('wxruby3', WXRuby3::WXRUBY_VERSION, :bin)]
    end

  end

  # source gem file
  file WXRuby3::Gem.gem_file('wxruby3', WXRuby3::WXRUBY_VERSION) => WXRuby3::Gem.manifest + ['ext/mkrf_conf_srcgem.rb'] do
    gemspec = WXRuby3::Gem.define_spec('wxruby3', WXRuby3::WXRUBY_VERSION) do |gem|
      gem.summary = %Q{wxWidgets extension for Ruby}
      gem.description = %Q{wxRuby3 is a Ruby library providing an extension for the wxWidgets C++ UI framework}
      gem.email = 'mcorino@m2c-software.nl'
      gem.homepage = "https://github.com/mcorino/wxRuby3"
      gem.authors = ['Martin Corino']
      gem.files = WXRuby3::Gem.manifest
      gem.extensions = ['ext/mkrf_conf_srcgem.rb']
      gem.require_paths = %w{lib}
      gem.executables = %w{}
      gem.required_ruby_version = '>= 2.5'
      gem.licenses = ['MIT']
      gem.add_dependency 'nokogiri', '~> 1.12'
      gem.add_dependency 'rake', '~> 12.0'
      gem.rdoc_options << '--exclude=\\.dll' << '--exclude=\\.so'
      gem.metadata = {
        "bug_tracker_uri"   => "https://github.com/mcorino/wxruby3/issues",
        "source_code_uri"   => "https://github.com/mcorino/wxruby3"
      }
      gem.post_install_message = <<~__MSG

        wxRuby3 has been successfully installed including the 'wxruby' utility.

        You can run the regression tests to verify the installation by executing:

        $ ./wxruby test

        The wxRuby3 sample selector can be run by executing:

        $ ./wxruby sampler

        Have fun using wxRuby3.
        __MSG
    end
    WXRuby3::Gem.build_gem(gemspec)
  end

  # binary gem file
  file WXRuby3::Gem.gem_file('wxruby3', WXRuby3::WXRUBY_VERSION, :bin) => WXRuby3::Gem.manifest(:bin) + ['ext/mkrf_conf_bingem.rb'] do
    if WXRuby3.config.get_config('with-wxwin')
      # prepare required wxWidgets shared libs
      WXRuby3::Install.wxwin_shlibs.each do |shlib|
        if File.symlink?(shlib)
          src_shlib = shlib
          src_shlib = File.join(File.dirname(shlib), File.basename(File.readlink(src_shlib))) while File.symlink?(src_shlib)
          ln_s(File.join('.', File.basename(src_shlib)), File.join('ext', File.basename(shlib)), :verbose => false)
        else
          cp(shlib, inshlib = File.join('ext', File.basename(shlib)), :verbose => false)
          WXRuby3.config.patch_rpath(inshlib, '$ORIGIN')
        end
      end
      # prepare wxRuby shared libs
      Dir["lib/*.#{WXRuby3.config.dll_mask}"].each do |shlib|
        WXRuby3.config.patch_rpath(shlib, '$ORIGIN:$ORIGIN/../ext')
      end
    end
    begin
      # create gemspec
      gemspec = WXRuby3::Gem.define_spec('wxruby3', WXRuby3::WXRUBY_VERSION, :bin) do |gem|
        gem.summary = %Q{wxWidgets extension for Ruby}
        gem.description = %Q{wxRuby3 is a Ruby library providing an extension for the wxWidgets C++ UI framework}
        gem.email = 'mcorino@m2c-software.nl'
        gem.homepage = "https://github.com/mcorino/wxRuby3"
        gem.authors = ['Martin Corino']
        gem.files = WXRuby3::Gem.manifest(:bin)
        gem.require_paths = %w{lib}
        gem.require_paths << 'ext' if WXRuby3.config.get_config('with-wxwin')
        gem.executables = %w{}
        gem.extensions = ['ext/mkrf_conf_bingem.rb']
        gem.required_ruby_version = ">= #{WXRuby3::Config.rb_ver_major}.#{WXRuby3::Config.rb_ver_minor}",
                                    "< #{WXRuby3::Config.rb_ver_major}.#{WXRuby3::Config.rb_ver_minor+1}"
        gem.licenses = ['MIT']
        gem.add_dependency 'rake', '~> 12.0'
        gem.rdoc_options << '--exclude=\\.dll' << '--exclude=\\.so'
      end
      WXRuby3::Gem.build_gem(gemspec)
    ensure
      if WXRuby3.config.get_config('with-wxwin')
        WXRuby3::Install.wxwin_shlibs.each { |shlib| rm_f(File.join('ext', File.basename(shlib)), :verbose => false) }
      end
    end
  end

  desc 'Build wxRuby 3 gem'
  task :gem => 'wxruby:gem:srcgem'

  desc 'Build wxRuby 3 binary gem'
  task :bingem => 'wxruby:gem:bingem'

end
