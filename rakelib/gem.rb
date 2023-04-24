###
# wxRuby3 rake gem support
# Copyright (c) M.J.N. Corino, The Netherlands
###

require 'set'
require 'rubygems'
require 'rubygems/package'
begin
  require 'rubygems/builder'
rescue LoadError
end

require_relative './lib/config'
require_relative './install'

module WXRuby3

  module Gem

    def self.manifest(gemtype = :src)
      # create MANIFEST list with included files
      manifest = Rake::FileList.new
      manifest.include %w[bin/*] # *nix executables in bin/
      manifest.exclude %w[bin/*.bat] unless WXRuby3.config.windows?
      manifest.include %w[lib/**/* samples/**/* tests/**/*]
      if gemtype == :bin
        if WXRuby3.config.get_config('with-wxwin')
          manifest.include "ext/*.#{WXRuby3.config.dll_mask}"
        end
        manifest.include 'ext/mkrf_conf_bingem.rb'
        manifest.include %w[rakelib/prepost.* rakelib/install.rb rakelib/lib/config.rb rakelib/lib/config/**/* rakelib/lib/ext/**/* rakelib/yard/**/*]
        manifest.include WXRuby3::BUILD_CFG
      else
        manifest.exclude "lib/*.#{WXRuby3.config.dll_mask}"
        manifest.include 'ext/wxruby3/wxruby.ico', 'ext/wxruby3/swig/**/*', 'ext/wxruby3/include/**/*'
        manifest.exclude 'ext/wxruby3/swig/classes/**/*'
        manifest.include 'ext/mkrf_conf_srcgem.rb'
        manifest.include 'rakelib/**/*'
        manifest.exclude %w[rakefile/install.rake rakelib/help.* rakelib/package.* rakelib/gem.* rakelib/bin.* rakelib/memcheck.* rakelib/memcheck/**/*]
      end
      manifest.include %w{LICENSE README.md CREDITS.md .yardopts}
      manifest
    end

    def self.define_spec(name, version, gemtype = :src, &block)
      gemspec = ::Gem::Specification.new(name, version)
      if gemtype == :bin
        platform = ::Gem::Platform.local.to_s
        # platform << "-#{WXRuby3::Config.rb_ver_major}.#{WXRuby3::Config.rb_ver_minor}"
        # if WXRuby3.config.get_config('with-wxwin')
        #   platform << "-#{WXRuby3.config.wx_version}"
        # end
        gemspec.platform = platform
      end
      gemspec.required_rubygems_version = ::Gem::Requirement.new(">= 0") if gemspec.respond_to? :required_rubygems_version=
      block.call(gemspec) if block_given?
      gemspec
    end

    def self.gem_name(name, version, gemtype = :src)
      define_spec(name, version, gemtype).full_name
    end

    def self.gem_file(name, version, gemtype = :src)
      File.join('pkg', "#{WXRuby3::Gem.gem_name(name, version, gemtype)}.gem")
    end

    def self.build_gem(gemspec)
      if defined?(::Gem::Package) && ::Gem::Package.respond_to?(:build)
        gem_file_name = ::Gem::Package.build(gemspec)
      else
        gem_file_name = ::Gem::Builder.new(gemspec).build
      end

      FileUtils.mkdir_p('pkg')

      FileUtils.mv(gem_file_name, 'pkg')
    end

  end

end
