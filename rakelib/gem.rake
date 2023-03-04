###
# wxRuby3 rake file
# Copyright (c) M.J.N. Corino, The Netherlands
###

if WXRuby3.is_bootstrapped?

  require_relative './gem'

  namespace :wxruby do

    namespace :gem do

      task :srcgem => [WXRuby3::Gem.gem_file('wxruby3', WXRuby3::WXRUBY_VERSION)]

      task :bingem => [WXRuby3::Gem.gem_file('wxruby3', WXRuby3::WXRUBY_VERSION, :bin)]
    end

  end

  # source gem file
  file WXRuby3::Gem.gem_file('wxruby3', WXRuby3::WXRUBY_VERSION) => WXRuby3::Gem.manifest + ['ext/mkrf_conf_srcgem.rb'] do
    gemspec = WXRuby3::Gem.define_spec('wxruby3', WXRuby3::WXRUBY_VERSION) do |gem|
      gem.summary = %Q{wxWidgets extension for Ruby}
      gem.description = %Q{wxWidgets extension for Ruby}
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
      # prepare required shared libs for wxWidgets
      WXRuby3::Gem.wxwin_shlibs.each { |shlib| ln(shlib, File.join('ext', File.basename(shlib), :verbose => false)) }
    end
    begin
      # create gemspec
      gemspec = WXRuby3::Gem.define_spec('wxruby3', WXRuby3::WXRUBY_VERSION, :bin) do |gem|
        gem.summary = %Q{wxWidgets extension for Ruby}
        gem.description = %Q{wxWidgets extension for Ruby}
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
        gem.licenses << 'Nonstandard' if WXRuby3.config.get_config('with-wxwin')
        gem.add_dependency 'rake', '~> 12.0'
        gem.rdoc_options << '--exclude=\\.dll' << '--exclude=\\.so'
      end
      WXRuby3::Gem.build_gem(gemspec)
    ensure
      if WXRuby3.config.get_config('with-wxwin')
        WXRuby3::Gem.wxwin_shlibs.each { |shlib| rm_f(File.join('ext', File.basename(shlib), :verbose => false)) }
      end
    end
  end

  desc 'Build wxRuby 3 gem'
  task :gem => 'wxruby:gem:srcgem'

  desc 'Build wxRuby 3 binary gem'
  task :bingem => 'wxruby:gem:bingem'

end
